#!/bin/bash

cols=$(($(tput cols)/2*2))
rows=$(($(tput lines)/2*2))
clear

declare -A maze=()
declare -A visited=()

generate()
{
  local permutation=($(echo {"$(($1 + 2)),$2","$(($1 - 2)),$2","$1,$(($2 + 2))","$1,$(($2 - 2))"} | tr ' ' '\n' | shuf | tr '\n' ' '))
  for mut in "${permutation[@]}";
  do
    if [ "${visited[$mut]}" == 0 ];
    then
      visited[$mut]=1
      local cord=(${mut//,/ })
      local x=$((($1+cord[0])/2))
      local y=$((($2+cord[1])/2))
      if [ $x -ne 1 ] && [ $y -ne 1 ] && [ $x -ne $((rows-1)) ] && [ $y -ne $((cols-1)) ];
      then
        maze[$x,$y]=' '
      fi
      generate ${cord[@]}
    fi
  done
}

draw()
{
  tput cup 0 0
  for (( i=1; i<rows; i++ ))
  do
    for (( j=1; j<cols; j++))
    do
      echo -n "${maze[$i,$j]}"
    done
    echo
  done
}

for (( i=1; i<rows; i++ ))
do
  for (( j=1; j<cols; j++))
  do
    visited[$i,$j]=0
    if [ $((i%2)) -eq 1 ] || [ $((j%2)) -eq 1 ];
    then
      maze[$i,$j]=X
    else
      maze[$i,$j]=' '
    fi
  done
done

generate 2 2

maze[1,2]=' '
maze[$((rows-1)),$((cols-2))]=" "

player_y=1
player_x=2
maze[$player_y,$player_x]=O
finish=0
tput civis

while [ $finish -eq 0 ];
do
  draw
  x=$player_x
  y=$player_y
  read -n 1 -s q
  case "$q" in
    [aA] ) ((x--));;
    [dD] ) ((x++));;
    [wW] ) ((y--));;
    [sS] ) ((y++));;
  esac
  if [ "${maze[$y,$x]}" == " " ];
  then
    maze[$player_y,$player_x]=" "
    player_x=$x
    player_y=$y
    maze[$player_y,$player_x]="O"
  fi
  if [ $player_x -eq $((cols-2)) ] && [ $player_y -eq $((rows-1)) ];
  then
    finish=1
    draw
  fi
done

tput cnorm
