From: Laurent Riffard <laurent.riffard@free.fr>
Subject: 2.6.23-rc[68]-mm: network hangs
Date: Fri, 28 Sep 2007 21:48:18 +0200
Message-ID: <46FD5A82.9070505@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070504020908000806060606"
To: Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756250AbXI1Ts2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070504020908000806060606
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi,

>From time to time, I experience some complete network hangs:

Suddenly, all network connections become unresponsive. Even "ping
127.0.0.1" doesn't work. SysRq-w does not show any blocked processus.

When such hang happen, I have to reboot (shutdown does work).

This is not easily reproducible: it happens several minutes after 
boot (could be 45 minutes or 2 hours). I do not use heavy networking 
apps (like P2P). My typical usage is a Gnome desktop with  browser, 
mailer, IM, video or audio streaming. 

I have a single PC connected to a DSL router via ethernet (so no LAN 
with NFS or CIFS).

This happens with 2.6.23-rc8-mm2 and 2.6.23-rc6-mm1. I can't remember 
when I first see this problem. Maybe 2 months ago.

I attached the output of "strace ping 127.0.0.1". How can I collect 
some more data when this problem happens ?

~~
laurent

--------------070504020908000806060606
Content-Type: text/plain;
 name="ping.strace"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ping.strace"

execve("/bin/ping", ["ping", "127.0.0.1"], [/* 42 vars */]) = 0
brk(0)                                  = 0x93ac000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f9b000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=57464, ...}) = 0
mmap2(NULL, 57464, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7f8c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/tls/i686/cmov/libresolv.so.2", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\0!\0\000"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0644, st_size=67408, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f8b000
mmap2(NULL, 75976, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f78000
mmap2(0xb7f87000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xf) = 0xb7f87000
mmap2(0xb7f89000, 6344, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f89000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/tls/i686/cmov/libc.so.6", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\0`\1\000"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0644, st_size=1307104, ...}) = 0
mmap2(NULL, 1312164, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7e37000
mmap2(0xb7f72000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13b) = 0xb7f72000
mmap2(0xb7f75000, 9636, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f75000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7e36000
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7e366c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
mprotect(0xb7f72000, 4096, PROT_READ)   = 0
munmap(0xb7f8c000, 57464)               = 0
socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) = 3
getuid32()                              = 0
setuid32(0)                             = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(1025), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
getsockname(4, {sa_family=AF_INET, sin_port=htons(44103), sin_addr=inet_addr("127.0.0.1")}, [16]) = 0
close(4)                                = 0
setsockopt(3, SOL_RAW, ICMP_FILTER, ~(ICMP_ECHOREPLY|ICMP_DEST_UNREACH|ICMP_SOURCE_QUENCH|ICMP_REDIRECT|ICMP_TIME_EXCEEDED|ICMP_PARAMETERPROB), 4) = 0
setsockopt(3, SOL_IP, IP_RECVERR, [1], 4) = 0
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [324], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [65536], 4) = 0
getsockopt(3, SOL_SOCKET, SO_RCVBUF, [131072], [4]) = 0
brk(0)                                  = 0x93ac000
brk(0x93cd000)                          = 0x93cd000
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f9a000
write(1, "PING 127.0.0.1 (127.0.0.1) 56(84"..., 49) = 49
setsockopt(3, SOL_SOCKET, SO_TIMESTAMP, [1], 4) = 0
setsockopt(3, SOL_SOCKET, SO_SNDTIMEO, "\1\0\0\0\0\0\0\0", 8) = 0
setsockopt(3, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0", 8) = 0
getpid()                                = 9353
rt_sigaction(SIGINT, {0x804b5b0, [], SA_INTERRUPT}, NULL, 8) = 0
rt_sigaction(SIGALRM, {0x804b5b0, [], SA_INTERRUPT}, NULL, 8) = 0
rt_sigaction(SIGQUIT, {0x804b5c0, [], SA_INTERRUPT}, NULL, 8) = 0
gettimeofday({1190968694, 793502}, NULL) = 0
ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}) = 0
ioctl(1, TIOCGWINSZ, {ws_row=52, ws_col=157, ws_xpixel=0, ws_ypixel=0}) = 0
gettimeofday({1190968694, 793762}, NULL) = 0
gettimeofday({1190968694, 793824}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0$\266\211$\0\1v\275\374F\340\34\f\0\10\t\n\v\f\r\16"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968695, 793022}, NULL) = 0
gettimeofday({1190968695, 793096}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0\373\267\211$\0\2w\275\374F\10\32\f\0\10\t\n\v\f\r"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968696, 793050}, NULL) = 0
gettimeofday({1190968696, 793123}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0\337\266\211$\0\3x\275\374F#\32\f\0\10\t\n\v\f\r\16"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968697, 793184}, NULL) = 0
gettimeofday({1190968697, 793259}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0V\265\211$\0\4y\275\374F\253\32\f\0\10\t\n\v\f\r\16"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968698, 793171}, NULL) = 0
gettimeofday({1190968698, 793244}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0d\264\211$\0\5z\275\374F\234\32\f\0\10\t\n\v\f\r\16"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968699, 793234}, NULL) = 0
gettimeofday({1190968699, 793306}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0%\263\211$\0\6{\275\374F\332\32\f\0\10\t\n\v\f\r\16"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968700, 793319}, NULL) = 0
gettimeofday({1190968700, 793393}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0\315\261\211$\0\7|\275\374F1\33\f\0\10\t\n\v\f\r\16"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EAGAIN (Resource temporarily unavailable)
gettimeofday({1190968701, 793371}, NULL) = 0
gettimeofday({1190968701, 793445}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.1")}, msg_iov(1)=[{"\10\0\230\260\211$\0\10}\275\374Fe\33\f\0\10\t\n\v\f\r"..., 64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, 0xbf982e34, 0)               = -1 EINTR (Interrupted system call)
--- SIGINT (Interrupt) @ 0 (0) ---
sigreturn()                             = ? (mask now [])
write(1, "\n", 1)                       = 1
write(1, "--- 127.0.0.1 ping statistics --"..., 34) = 34
write(1, "8 packets transmitted, 0 receive"..., 65) = 65
write(1, "\n", 1)                       = 1
exit_group(1)                           = ?

--------------070504020908000806060606--
