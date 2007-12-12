From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Wed, 12 Dec 2007 12:25:34 -0600
Message-ID: <4760279E.1080203@nortel.com>
References: <475D7901.1040900@nortel.com> <475D7D70.5030502@nortel.com> <47600A6E.8000202@nortel.com> <47601059.8020203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060504040607060505060303"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:40249 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbXLLS0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:26:16 -0500
In-Reply-To: <47601059.8020203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060504040607060505060303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet wrote:
> Chris Friesen a écrit :
>> Is this expected behaviour?
> 
> Probably not... Still a 2.6.14 kernel ?

Yep.  Embedded hardware, so I'm unable to test with a more recent kernel.

> Could you send the result of :
> 
> strace ip neigh show

I've attached two strace runs, one of "ip neigh show" and one of "ip 
neigh show 10.41.18.101".

Chris

--------------060504040607060505060303
Content-Type: text/plain;
 name="trace.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="trace.txt"

root@typhoon-base-unit0:/tftpboot/cnp/0-0-5-0/0-0-5-0> strace ip neigh show
execve("/sbin/ip", ["ip", "neigh", "show"], [/* 14 vars */]) = 0
uname({sys="Linux", node="typhoon-base-unit0", ...}) = 0
brk(0)                                  = 0x806b000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=58478, ...}) = 0
mmap2(NULL, 58478, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7f56000
close(3)                                = 0
open("/lib/libresolv.so.2", O_RDONLY)   = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320\"\0"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=75541, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f55000
mmap2(NULL, 71816, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7f43000
mmap2(0xb7f51000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe) = 0xb7f51000
mmap2(0xb7f53000, 6280, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f53000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\216O\1"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1407983, ...}) = 0
mmap2(NULL, 1146076, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7e2b000
mmap2(0xb7f39000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x10d) = 0xb7f39000
mmap2(0xb7f41000, 7388, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f41000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7e2a000
mprotect(0xb7f39000, 20480, PROT_READ)  = 0
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7e2a6b0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
munmap(0xb7f56000, 58478)               = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [32768], 4) = 0
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=6150, groups=00000000}, [12]) = 0
time(NULL)                              = 1197465643
sendto(3, "\24\0\0\0\22\0\1\3,\340_G\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\364\0\0\0\20\0\2\0,\340_G\6\30\0\0\0\0\1\0\1\0\0\0C\30"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3544
brk(0)                                  = 0x806b000
brk(0x808c000)                          = 0x808c000
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0,\340_G\6\30\0\0\0\0\0\0\1\0\0\0C\30\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 20
sendto(3, "\24\0\0\0\36\0\1\3-\340_G\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"X\0\0\0\34\0\2\0-\340_G\6\30\0\0\n\0\0\0\7\0\0\0@\0\0\5"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 264
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0-\340_G\6\30\0\0\0\0\0\0\7\0\0\0@\0\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 20
exit_group(0)                           = ?
Process 6150 detached






root@typhoon-base-unit0:/tftpboot/cnp/0-0-5-0/0-0-5-0> ip neigh show 10.41.18.101
10.41.18.101 dev eth6 lladdr 00:0e:0c:5e:95:bd REACHABLE
root@typhoon-base-unit0:/tftpboot/cnp/0-0-5-0/0-0-5-0> strace ip neigh show 10.41.18.101
execve("/sbin/ip", ["ip", "neigh", "show", "10.41.18.101"], [/* 14 vars */]) = 0
uname({sys="Linux", node="typhoon-base-unit0", ...}) = 0
brk(0)                                  = 0x806b000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=58478, ...}) = 0
mmap2(NULL, 58478, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7fd5000
close(3)                                = 0
open("/lib/libresolv.so.2", O_RDONLY)   = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320\"\0"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=75541, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fd4000
mmap2(NULL, 71816, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7fc2000
mmap2(0xb7fd0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe) = 0xb7fd0000
mmap2(0xb7fd2000, 6280, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7fd2000
close(3)                                = 0
open("/lib/libc.so.6", O_RDONLY)        = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\216O\1"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1407983, ...}) = 0
mmap2(NULL, 1146076, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7eaa000
mmap2(0xb7fb8000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x10d) = 0xb7fb8000
mmap2(0xb7fc0000, 7388, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7fc0000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7ea9000
mprotect(0xb7fb8000, 20480, PROT_READ)  = 0
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7ea96b0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
munmap(0xb7fd5000, 58478)               = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 3
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [32768], 4) = 0
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=7536, groups=00000000}, [12]) = 0
time(NULL)                              = 1197465790
sendto(3, "\24\0\0\0\22\0\1\3\277\340_G\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\364\0\0\0\20\0\2\0\277\340_Gp\35\0\0\0\0\1\0\1\0\0\0C"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3544
brk(0)                                  = 0x806b000
brk(0x808c000)                          = 0x808c000
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\277\340_Gp\35\0\0\0\0\0\0\1\0\0\0C\30"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 20
sendto(3, "\24\0\0\0\36\0\1\3\300\340_G\0\0\0\0\2\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"L\0\0\0\34\0\2\0\300\340_Gp\35\0\0\2\0\0\0\r\0\0\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 912
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 11), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe3000
write(1, "10.41.18.101 dev eth6 lladdr 00:"..., 5710.41.18.101 dev eth6 lladdr 00:0e:0c:5e:95:bd REACHABLE) = 57
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\300\340_Gp\35\0\0\0\0\0\0\r\0\0\0\2\0"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 20
munmap(0xb7fe3000, 4096)                = 0
exit_group(0)                           = ?
Process 7536 detached

--------------060504040607060505060303--
