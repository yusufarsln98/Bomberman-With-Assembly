# null:         "\0"        # ASCII code: 0
# delimiter:    "_"         # ASCII code: 95
# bomb:         "O"         # ASCII code: 79
# empty:        "."         # ASCII code: 46
# newline:      "\n"        # ASCII code: 10

.data
    newline: .asciiz "\n"
    welcome: .asciiz "Welcome to the BOMBERMAN!\n"
    goodbye: .asciiz "Goodbye!\n"
    ask_rows: .asciiz "Please enter the number of rows: "
    ask_cols: .asciiz "Please enter the number of columns: "
    ask_grid: .asciiz "Please enter the grid:\n"
    initial_state: .asciiz "Initial state:\n"
    final_state: .asciiz "Final state:\n"
    grid: .space 2551 # for max 50x50 grid (+50 for delimeter, +1 for null terminator)
    bug_detecter: .asciiz "Here I am!\n"

.text
    # registers that must not be modified
    # $s0: will keep number of the rows
    # $s1: will keep number of the cols
    # $s2: will keep the array size
    # $s3: will keep the ascii code for '_'
    # $s4: will keep the ascii code for 'O'
    # $t9: to save $ra temporarily
    main:

        # set delimeter -> $s3 = '_'
        li $s3, 95 # ascii code for '_'

        # set bomb -> $s4 = 'O'
        li $s4, 79 # ascii code for 'O'

        # welcome user -> printf("%s", welcome)
        la $a0, welcome
        li $v0, 4
        syscall
        jal print_newline

        # ask for rows -> printf("%s", ask_rows")
        la $a0, ask_rows
        li $v0, 4
        syscall
        
        # read rows -> scanf("%d", &s0)
        li $v0, 5
        syscall
        move $s0, $v0 

        # ask for columns -> printf("%s", ask_cols)
        la $a0, ask_cols 
        li $v0, 4
        syscall

        # read cols -> scanf("%d", &s1)
        li $v0, 5
        syscall
        move $s1, $v0 

        # ask for grid -> printf("%s", ask_grid)
        la $a0, ask_grid
        li $v0, 4
        syscall

        # read grid -> scanf("%s", grid)
        la $a0, grid
        li $a1, 2552
        li $v0, 8
        syscall

        # new line -> print_newline()
        jal print_newline

        # print grid -> print_grid()
        jal initial_grid

        # new line -> print_newline()
        jal print_newline

        # final_grid -> final_grid()
        jal final_grid

        # new line -> print_newline()
        jal print_newline

        # exit -> exit()
        j exit
    
    initial_grid:
        # temp registers to use in loops
        # $t0: i (count array size)
        # $t2: &grid
        # $s3: ascii code for '_'
        # $t9: to save $ra temporarily
        # $s2: ARRAY_SIZE

        # print initial state -> printf("%s", initial_state)
        la $a0, initial_state
        li $v0, 4
        syscall

        # int i = 0
        li $t0, 0 # i

        # ARRAY_SIZE (s2) is = [row * col + row (for delimiters) + 1 (for null terminator)]
        # $s2 = row * col + row + 1 
        mul $s2, $s0, $s1
        add $s2, $s2, $s0
        addi $s2, $s2, 1

        # get address of grid
        # $t2 = &grid
        la $t2, grid

        # loop through the grid
        initial_grid_loop:
            # if i == ARRAY_SIZE then exit from loop
            beq $t0, $s2, initial_grid_loop_exit

            # get next char from grid -> $a0 = *grid 
            lb $a0, ($t2)

            # if char not equal to delimeter, pass new line; else print a newline
            # (a0 != '_') then initial_grid_loop_pass_new_line
            bne $a0, $s3, initial_grid_loop_pass_new_line

            # print newline -> print_newline()            
            move $t9, $ra # save $ra temporarily
            jal print_newline
            move $ra, $t9 # restore $ra
            
            # increment i to pass delimiter -> i++
            addi $t0, $t0, 1 

            # increment address of grid to pass delimiter -> grid++
            addi $t2, $t2, 1

            # if char is newline, exit from loop
            lb $a0, ($t2)
            beq $a0, 10, final_grid_loop_exit # ascii code for '\n'

            initial_grid_loop_pass_new_line:
                # print the char
                lb $a0, ($t2)
                li $v0, 11
                syscall

                # increment i -> i++
                addi $t0, $t0, 1

                # increment address of grid -> grid++
                addi $t2, $t2, 1

                # jump to initial_grid_loop to 
                # continue loop
                j initial_grid_loop

        # exit from loop
        initial_grid_loop_exit:
            jr $ra

    final_grid:
        # temp registers to use in loops
        # $t0: i (count array size)
        # $s2: ARRAY_SIZE
        # $t2: &grid
        # $s3: ascii code for '_'
        # $s4: ascii code for 'O'
        # $t9: to save $ra temporarily
        # print final state -> printf("%s", final_state)
        la $a0, final_state
        li $v0, 4
        syscall

        # int i = 0
        li $t0, 0 # i

        # ARRAY_SIZE (s2) is = [row * col + row (for delimiters) + 1 (for null terminator)]
        # $s2 = row * col + row + 1 
        mul $s2, $s0, $s1
        add $s2, $s2, $s0
        addi $s2, $s2, 1

        # get address of grid
        # $t2 = &grid
        la $t2, grid

        # loop through the grid
        final_grid_loop:
            # if i == ARRAY_SIZE then exit from loop
            beq $t0, $s2, final_grid_loop_exit

            # get next char from grid -> $a0 = *grid 
            lb $a0, ($t2)

            # if char not equal to delimeter, pass new line; else print a newline
            # -> (a0 != '_') then final_grid_loop_pass_new_line
            bne $a0, $s3, final_grid_loop_pass_new_line

            # print newline -> print_newline()            
            move $t9, $ra # save $ra temporarily
            jal print_newline
            move $ra, $t9 # restore $ra
            
            # increment i to pass delimiter -> i++
            addi $t0, $t0, 1 

            # increment address of grid to pass delimiter -> grid++
            addi $t2, $t2, 1  

            # if char is newline, exit from loop
            lb $a0, ($t2)
            beq $a0, 10, final_grid_loop_exit # ascii code for '\n'


            # buraya yapistir
                final_grid_loop_pass_new_line:
                # get the char -> $a0 = *grid                
                lb $a0, ($t2)

                # if the char, or one of its neighbors is a bomb, 
                # the bomb explodes and the cell becomes empty
                
                # if char is a bomb, explode
                beq $a0, $s4, explode

                # get position of the char in row
                # $t4 = i % (col + 1) // +1 for delimiter
                addi $t4, $s1, 1 # $t4 = col + 1
                div $t5, $t0, $t4 # $t5 = i / (col + 1)
                mfhi $t5 # $t5 = i % (col + 1)

                # if t5(pos in row) + 1 >= col + 1, 
                # then we can't check the next neighbor (out of bounds)
                addi $t6, $t5, 1 # $t6 = t5 + 1
                bge $t6, $t4, dont_check_next_neighbor
                # if next neighbor is a bomb, explode
                lb $a0, 1($t2)
                beq $a0, $s4, explode

                dont_check_next_neighbor:
                # if t5(pos in row) - 1 < 0,
                # then we can't check the previous neighbor (out of bounds)
                blt $t5, 1, dont_check_previous_neighbor

                # if previous neighbor is a bomb, explode
                lb $a0, -1($t2)
                beq $a0, $s4, explode  

                
                dont_check_previous_neighbor:
                # if current position + col + 1 >= ARRAY_SIZE,
                # then we can't check the neighbor below (out of bounds)
                # $t6 = i + col + 1
                add $t6, $t0, $s1
                addi $t6, $t6, 1
                bge $t6, $s2, dont_check_neighbor_below

                
                # if neighbor in below is a bomb, explode
                dont_check_neighbor_below:
                add $t4, $t2, $s1 # $t4 = grid + col
                addi $t4, $t4, 1 # +1 for delimiter
                lb $a0, ($t4)
                beq $a0, $s4, explode

                # if current position - col - 1 < 0,
                # then we can't check the neighbor above (out of bounds)
                # $t6 = i - col - 1
                mul $t5, $s1, -1 # $t5 = -col
                add $t6, $t0, $t5 # $t6 = i - col
                addi $t6, $t6, -1 # -1 for delimiter
                blt $t6, 0, dont_check_neighbor_above

                # if neighbor in above is a bomb, explode
                mul $t5, $s1, -1 # $t5 = -col
                add $t4, $t2, $t5 # $t4 = grid - col
                addi $t4, $t4, -1 # -1 for delimiter
                lb $a0, ($t4)
                beq $a0, $s4, explode

                dont_check_neighbor_above:
                j dont_explode

                explode:
                    # print empty -> printf("%c", '.')
                    li $a0, 46 # ascii code for '.'
                    li $v0, 11
                    syscall
                    j next

                dont_explode:
                    # print bomb -> printf("%c", 'O')
                    li $a0, 79 # ascii code for 'O'
                    li $v0, 11
                    syscall
                    j next

                next:
                    # increment i -> i++
                    addi $t0, $t0, 1

                    # increment address of grid -> grid++
                    addi $t2, $t2, 1

                    # jump to final_grid_loop to 
                    # continue loop
                    j final_grid_loop

        # exit from loop
        final_grid_loop_exit:
            jr $ra

    # before calling helper functions, do not forget 
    # save and restore $ra to come back     
    print_newline:
        # print newline
        la $a0, newline
        li $v0, 4
        syscall
        jr $ra

    exit:
        # print goodbye message
        la $a0, goodbye
        li $v0, 4
        syscall

        # exit
        li $v0, 10
        syscall
