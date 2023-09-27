#!/bin/bash

# проверяем, что передан хотя бы один параметр
if [ $# -lt 1 ]; then
    echo "Параметры не найдены"
    exit 1
fi

pid=$1 # первый параметр - идентификатор процесса
fd=$2 # второй параметр - строка fd (необязательный)

# проверяем, что процесс с таким pid существует
if [ ! -d /proc/$pid ]; then
    echo "Процесс с pid = $pid не найден"
    exit 2
fi

# получаем наименование исполняемого файла из /proc/$pid/comm
exe=$(cat /proc/$pid/comm)

# получаем идентификатор родительского процесса из /proc/$pid/status
ppid=$(grep PPid /proc/$pid/status | awk '{print $2}')

# выводим информацию на консоль
echo "Имя: $exe"
echo "Pid: $pid"
echo "PPid: $ppid"

# если передана строка fd, то выводим перечень дескрипторов из /proc/$pid/fd
if [ -n "$fd" ]; then
    echo "Дескрипторы потоков:"
    ls -l /proc/$pid/fd | awk '{print "fd = "$9}' # выводим номера дескрипторов с префиксом fd =
fi

# пока pid не равен 1 (идентификатор процесса system), повторяем цикл
while [ $pid -ne 1 ]; do
    # обновляем pid на ppid (переходим к родительскому процессу)
    pid=$ppid

    # получаем наименование исполняемого файла из /proc/$pid/comm
    exe=$(cat /proc/$pid/comm)

    # получаем идентификатор родительского процесса из /proc/$pid/status
    ppid=$(grep PPid /proc/$pid/status | awk '{print $2}')

    # выводим информацию на консоль
    echo "Имя: $exe"
    echo "Pid: $pid"
    echo "PPid: $ppid"
done