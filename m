From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Thu, 30 Jan 2014 21:31:20 +0100
Message-ID: <20140130203120.GB24418@sesse.net>
References: <20140118191107.GA21979@sesse.net>
 <20140119181806.GC16462@order.stressinduktion.org>
 <20140120184025.GA19972@sesse.net>
 <20140130104709.GA21178@sesse.net>
 <20140130141747.GC25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:40865 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaA3UbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 15:31:24 -0500
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1W8yGe-00049V-Lh
	for netdev@vger.kernel.org; Thu, 30 Jan 2014 21:31:20 +0100
Received: from sesse by pannekake.samfundet.no with local (Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1W8yGe-0005kY-4X
	for netdev@vger.kernel.org; Thu, 30 Jan 2014 21:31:20 +0100
Content-Disposition: inline
In-Reply-To: <20140130141747.GC25336@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Jan 30, 2014 at 03:17:47PM +0100, Hannes Frederic Sowa wrote:
> Can you give a bit more background what multicast application you are running
> on the box and also post a cat /proc/net/igmp?

I'm trying to join a multicast video stream. I've tried several ones that
I've used in the past; MPlayer, VLC, XBMC.

> (For the application info an strace how the join to the multicast address would be
> interesting.)

Included.

> I guess a workaround would be to bind the join to a specific interface.

I don't think any of the software can do that out of the box; I'd have to
patch them if so.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="mplayer-strace.txt"

execve("/usr/bin/mplayer", ["mplayer", "udp://@239.1.1.20:1234"], ["XDG_SESSION_ID=c6", "TERM=rxvt-unicode", "SHELL=/bin/bash", "XDG_SESSION_COOKIE=042342bb5b33b"..., "SSH_CLIENT=2001:67c:a4:1:e0b2:78"..., "SSH_TTY=/dev/pts/0", "USER=sesse", "LS_COLORS=rs=0:di=01;34:ln=01;36"..., "MAIL=/var/mail/sesse", "PATH=/usr/local/bin:/usr/bin:/bi"..., "PWD=/home/sesse", "LANG=nb_NO.UTF-8", "HISTCONTROL=ignoreboth", "SHLVL=1", "HOME=/home/sesse", "LANGUAGE=nb_NO:nb:no_NO:no:en", "LOGNAME=sesse", "SSH_CONNECTION=2001:67c:a4:1:e0b"..., "DISPLAY=:0", "XDG_RUNTIME_DIR=/run/user/1000", "_=/usr/bin/strace"]) = 0
brk(0)                                  = 0x7ff24dc04000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf35000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_dev=makedev(254, 0), st_ino=2696180, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=264, st_size=128642, st_atime=2014/01/30-01:50:01, st_mtime=2014/01/23-01:47:27, st_ctime=2014/01/23-01:47:27}) = 0
mmap(NULL, 128642, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7ff24bf15000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libncurses.so.5", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260l\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328942, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=296, st_size=147024, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-19:26:38, st_ctime=2014/01/22-21:56:25}) = 0
mmap(NULL, 2242632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24baf2000
mprotect(0x7ff24bb15000, 2093056, PROT_NONE) = 0
mmap(0x7ff24bd14000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22000) = 0x7ff24bd14000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libtinfo.so.5", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\316\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328940, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=344, st_size=171736, st_atime=2014/01/29-22:05:02, st_mtime=2014/01/20-19:26:42, st_ctime=2014/01/22-21:56:22}) = 0
mmap(NULL, 2268928, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24b8c8000
mprotect(0x7ff24b8ed000, 2097152, PROT_NONE) = 0
mmap(0x7ff24baed000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x25000) = 0x7ff24baed000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsmbclient.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200w\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647619, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=296, st_size=143608, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:28, st_ctime=2014/01/18-21:57:24}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf14000
mmap(NULL, 2238784, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24b6a5000
mprotect(0x7ff24b6c7000, 2093056, PROT_NONE) = 0
mmap(0x7ff24b8c6000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x21000) = 0x7ff24b8c6000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libpng12.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0H\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328829, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=320, st_size=158616, st_atime=2014/01/30-07:53:43, st_mtime=2013/10/06-02:09:06, st_ctime=2013/10/27-22:58:19}) = 0
mmap(NULL, 2253872, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24b47e000
mprotect(0x7ff24b4a4000, 2093056, PROT_NONE) = 0
mmap(0x7ff24b6a3000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x25000) = 0x7ff24b6a3000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@%\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328821, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=200, st_size=96888, st_atime=2014/01/29-23:05:01, st_mtime=2013/05/03-18:01:47, st_ctime=2013/06/10-01:07:37}) = 0
mmap(NULL, 2191880, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24b266000
mprotect(0x7ff24b27d000, 2093056, PROT_NONE) = 0
mmap(0x7ff24b47c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) = 0x7ff24b47c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libmng.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \245\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647809, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1120, st_size=567072, st_atime=2014/01/30-21:29:36, st_mtime=2011/09/16-18:20:32, st_ctime=2012/08/27-01:23:52}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf13000
mmap(NULL, 2662288, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24afdc000
mprotect(0x7ff24b062000, 2093056, PROT_NONE) = 0
mmap(0x7ff24b261000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x85000) = 0x7ff24b261000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libjpeg.so.8", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`G\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=2221399, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=480, st_size=238360, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/03-23:07:47, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2333440, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24ada2000
mprotect(0x7ff24addb000, 2097152, PROT_NONE) = 0
mmap(0x7ff24afdb000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x39000) = 0x7ff24afdb000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libopenjpeg.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0pL\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646737, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=288, st_size=139832, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/12-16:14:44, st_ctime=2013/12/14-02:44:43}) = 0
mmap(NULL, 2235064, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24ab80000
mprotect(0x7ff24aba1000, 2093056, PROT_NONE) = 0
mmap(0x7ff24ada0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x20000) = 0x7ff24ada0000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgif.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\34\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648697, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=72, st_size=36256, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/07-19:36:04, st_ctime=2013/12/14-02:45:59}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf12000
mmap(NULL, 2131472, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24a977000
mprotect(0x7ff24a97f000, 2093056, PROT_NONE) = 0
mmap(0x7ff24ab7e000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7000) = 0x7ff24ab7e000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libasound.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\373\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647310, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1992, st_size=1011856, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/19-16:49:48, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 3107272, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24a680000
mprotect(0x7ff24a76f000, 2093056, PROT_NONE) = 0
mmap(0x7ff24a96e000, 36864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xee000) = 0x7ff24a96e000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\16\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=656003, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14664, st_atime=2014/01/30-00:00:01, st_mtime=2013/11/29-18:00:15, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2109720, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24a47c000
mprotect(0x7ff24a47f000, 2093056, PROT_NONE) = 0
mmap(0x7ff24a67e000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff24a67e000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@l\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=655734, st_mode=S_IFREG|0755, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=272, st_size=131593, st_atime=2014/01/29-22:10:01, st_mtime=2013/11/29-18:00:20, st_ctime=2014/01/11-22:06:37}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf11000
mmap(NULL, 2208688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24a260000
mprotect(0x7ff24a277000, 2093056, PROT_NONE) = 0
mmap(0x7ff24a476000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) = 0x7ff24a476000
mmap(0x7ff24a478000, 13232, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff24a478000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libbluray.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260E\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648485, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=472, st_size=236368, st_atime=2014/01/30-07:53:43, st_mtime=2014/01/14-15:15:28, st_ctime=2014/01/18-21:54:57}) = 0
mmap(NULL, 2331720, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24a026000
mprotect(0x7ff24a05e000, 2093056, PROT_NONE) = 0
mmap(0x7ff24a25d000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x37000) = 0x7ff24a25d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdvdread.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@'\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646908, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=248, st_size=120672, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/08-23:45:11, st_ctime=2014/01/18-21:55:47}) = 0
mmap(NULL, 2218136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff249e08000
mprotect(0x7ff249e24000, 2097152, PROT_NONE) = 0
mmap(0x7ff24a024000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1c000) = 0x7ff24a024000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/libcdio_cdda.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\30\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1366272, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=64, st_size=29104, st_atime=2014/01/30-21:29:36, st_mtime=2013/11/19-13:26:14, st_ctime=2013/11/29-22:56:13}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf10000
mmap(NULL, 2124296, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff249c01000
mprotect(0x7ff249c08000, 2093056, PROT_NONE) = 0
mmap(0x7ff249e07000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6000) = 0x7ff249e07000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/libcdio.so.13", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0Pf\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1365036, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=272, st_size=132864, st_atime=2014/01/30-21:29:36, st_mtime=2013/11/19-13:26:14, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2243568, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2499dd000
mprotect(0x7ff2499fd000, 2093056, PROT_NONE) = 0
mmap(0x7ff249bfc000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1f000) = 0x7ff249bfc000
mmap(0x7ff249bfd000, 15344, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff249bfd000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/libcdio_paranoia.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\17\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1366273, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=27408, st_atime=2014/01/30-21:29:36, st_mtime=2013/11/19-13:26:14, st_ctime=2013/11/29-22:56:13}) = 0
mmap(NULL, 2122680, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2497d6000
mprotect(0x7ff2497dc000, 2097152, PROT_NONE) = 0
mmap(0x7ff2499dc000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6000) = 0x7ff2499dc000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libfreetype.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \327\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646774, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1320, st_size=671432, st_atime=2014/01/30-07:53:43, st_mtime=2013/12/25-10:08:25, st_ctime=2014/01/18-21:52:22}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf0f000
mmap(NULL, 2766696, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff249532000
mprotect(0x7ff2495d0000, 2093056, PROT_NONE) = 0
mmap(0x7ff2497cf000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9d000) = 0x7ff2497cf000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libfontconfig.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240l\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646762, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=488, st_size=244720, st_atime=2014/01/30-21:29:36, st_mtime=2013/11/23-20:20:54, st_ctime=2013/11/29-22:54:25}) = 0
mmap(NULL, 2340456, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2492f6000
mprotect(0x7ff249330000, 2093056, PROT_NONE) = 0
mmap(0x7ff24952f000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x39000) = 0x7ff24952f000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libfribidi.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \26\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647626, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=192, st_size=92232, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/09-08:35:45, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2187528, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2490df000
mprotect(0x7ff2490f5000, 2093056, PROT_NONE) = 0
mmap(0x7ff2492f4000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7ff2492f4000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libass.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\3003\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647473, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=296, st_size=144704, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/15-18:46:50, st_ctime=2013/10/27-23:01:24}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf0e000
mmap(NULL, 2240040, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248ebc000
mprotect(0x7ff248edf000, 2093056, PROT_NONE) = 0
mmap(0x7ff2490de000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22000) = 0x7ff2490de000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libenca.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\322\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646727, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=416, st_size=208432, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-15:58:41, st_ctime=2014/01/22-21:56:43}) = 0
mmap(NULL, 2303744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248c89000
mprotect(0x7ff248cb6000, 2097152, PROT_NONE) = 0
mmap(0x7ff248eb6000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2d000) = 0x7ff248eb6000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libbz2.so.1.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\27\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328795, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=66792, st_atime=2014/01/30-07:35:01, st_mtime=2013/08/13-00:20:35, st_ctime=2013/08/18-00:58:11}) = 0
mmap(NULL, 2162056, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248a79000
mprotect(0x7ff248a88000, 2093056, PROT_NONE) = 0
mmap(0x7ff248c87000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe000) = 0x7ff248c87000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/liblzo2.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0&\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328960, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=272, st_size=133200, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/26-21:34:15, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf0d000
mmap(NULL, 2228464, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248858000
mprotect(0x7ff248878000, 2093056, PROT_NONE) = 0
mmap(0x7ff248a77000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1f000) = 0x7ff248a77000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libmad.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\34\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649006, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=264, st_size=129208, st_atime=2014/01/30-21:29:36, st_mtime=2013/05/20-18:41:09, st_ctime=2013/06/10-00:47:39}) = 0
mmap(NULL, 2224472, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248638000
mprotect(0x7ff248656000, 2097152, PROT_NONE) = 0
mmap(0x7ff248856000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e000) = 0x7ff248856000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libogg.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\32\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648731, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=26432, st_atime=2014/01/30-21:29:36, st_mtime=2013/05/11-23:05:41, st_ctime=2013/05/12-17:26:56}) = 0
mmap(NULL, 2121744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248431000
mprotect(0x7ff248437000, 2093056, PROT_NONE) = 0
mmap(0x7ff248636000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff248636000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/libvorbisidec.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320$\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1363087, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=240, st_size=116536, st_atime=2014/01/30-21:29:36, st_mtime=2012/06/25-23:41:21, st_ctime=2013/08/18-01:02:08}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf0c000
mmap(NULL, 2211736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff248215000
mprotect(0x7ff248231000, 2093056, PROT_NONE) = 0
mmap(0x7ff248430000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b000) = 0x7ff248430000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libspeex.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320'\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647372, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=208, st_size=100240, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/26-18:25:05, st_ctime=2013/10/27-23:01:27}) = 0
mmap(NULL, 2195472, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff247ffc000
mprotect(0x7ff248013000, 2097152, PROT_NONE) = 0
mmap(0x7ff248213000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x17000) = 0x7ff248213000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgsm.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \23\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649700, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=112, st_size=52216, st_atime=2014/01/30-21:29:36, st_mtime=2012/04/12-19:30:57, st_ctime=2012/08/27-01:22:02}) = 0
mmap(NULL, 2147376, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff247def000
mprotect(0x7ff247dfc000, 2093056, PROT_NONE) = 0
mmap(0x7ff247ffb000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xc000) = 0x7ff247ffb000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libtheoradec.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \31\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649738, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=232, st_size=113024, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/11-16:34:50, st_ctime=2012/08/27-01:22:05}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf0b000
mmap(NULL, 2208016, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff247bd3000
mprotect(0x7ff247bee000, 2093056, PROT_NONE) = 0
mmap(0x7ff247ded000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a000) = 0x7ff247ded000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libmpg123.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240L\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648629, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=584, st_size=294808, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/07-12:33:26, st_ctime=2013/10/27-23:02:49}) = 0
mmap(NULL, 2455784, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24797b000
mprotect(0x7ff2479c1000, 2097152, PROT_NONE) = 0
mmap(0x7ff247bc1000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x46000) = 0x7ff247bc1000
mmap(0x7ff247bc3000, 63720, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff247bc3000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/liba52-0.7.4.so", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\f\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=729258, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=112, st_size=52648, st_atime=2014/01/30-21:29:36, st_mtime=2011/05/06-12:22:40, st_ctime=2012/08/27-01:24:34}) = 0
mmap(NULL, 2151616, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24776d000
mprotect(0x7ff24777a000, 2093056, PROT_NONE) = 0
mmap(0x7ff247979000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xc000) = 0x7ff247979000
mmap(0x7ff24797a000, 1216, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff24797a000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdca.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\21\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648657, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=360, st_size=178176, st_atime=2014/01/30-21:29:36, st_mtime=2013/09/24-16:43:36, st_ctime=2013/10/27-23:01:30}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf0a000
mmap(NULL, 2273440, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff247541000
mprotect(0x7ff24756c000, 2093056, PROT_NONE) = 0
mmap(0x7ff24776b000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2a000) = 0x7ff24776b000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libfaad.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\25\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649680, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=528, st_size=264600, st_atime=2014/01/30-21:29:36, st_mtime=2012/03/18-14:10:32, st_ctime=2012/08/27-01:21:59}) = 0
mmap(NULL, 2359688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff247300000
mprotect(0x7ff24733d000, 2097152, PROT_NONE) = 0
mmap(0x7ff24753d000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3d000) = 0x7ff24753d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libopus.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`#\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647696, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=584, st_size=292752, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/10-10:28:00, st_ctime=2013/12/14-02:45:31}) = 0
mmap(NULL, 2387984, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2470b8000
mprotect(0x7ff2470ff000, 2093056, PROT_NONE) = 0
mmap(0x7ff2472fe000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x46000) = 0x7ff2472fe000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/libbs2b.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\26\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1360578, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=23440, st_atime=2014/01/30-21:29:36, st_mtime=2011/07/26-18:59:42, st_ctime=2013/08/18-01:02:06}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf09000
mmap(NULL, 2118736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff246eb2000
mprotect(0x7ff246eb8000, 2093056, PROT_NONE) = 0
mmap(0x7ff2470b7000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff2470b7000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/librtmp.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200V\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647156, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=224, st_size=108272, st_atime=2014/01/30-21:29:36, st_mtime=2013/05/01-12:36:32, st_ctime=2013/05/12-17:23:55}) = 0
mmap(NULL, 2203512, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff246c98000
mprotect(0x7ff246cb1000, 2097152, PROT_NONE) = 0
mmap(0x7ff246eb1000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x19000) = 0x7ff246eb1000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libopencore-amrnb.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\r\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648102, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=344, st_size=170072, st_atime=2014/01/30-21:29:36, st_mtime=2012/03/18-19:23:28, st_ctime=2012/08/27-01:24:34}) = 0
mmap(NULL, 2265160, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff246a6e000
mprotect(0x7ff246a97000, 2093056, PROT_NONE) = 0
mmap(0x7ff246c96000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x28000) = 0x7ff246c96000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libopencore-amrwb.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\n\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648104, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=168, st_size=79880, st_atime=2014/01/30-21:29:36, st_mtime=2012/03/18-19:23:28, st_ctime=2012/08/27-01:24:34}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf08000
mmap(NULL, 2175040, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24685a000
mprotect(0x7ff24686d000, 2093056, PROT_NONE) = 0
mmap(0x7ff246a6c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12000) = 0x7ff246a6c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdv.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20J\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646988, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=256, st_size=124824, st_atime=2014/01/30-21:29:36, st_mtime=2012/12/17-17:36:03, st_ctime=2013/01/20-14:51:28}) = 0
mmap(NULL, 2274816, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24662e000
mprotect(0x7ff246649000, 2097152, PROT_NONE) = 0
mmap(0x7ff246849000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b000) = 0x7ff246849000
mmap(0x7ff24684d000, 50688, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff24684d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libcrystalhd.so.3", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340[\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646680, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=232, st_size=111272, st_atime=2014/01/30-21:29:36, st_mtime=2013/03/02-23:50:07, st_ctime=2013/03/03-16:10:49}) = 0
mmap(NULL, 2206600, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff246413000
mprotect(0x7ff24642d000, 2097152, PROT_NONE) = 0
mmap(0x7ff24662d000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a000) = 0x7ff24662d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxvidcore.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0A\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647548, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1400, st_size=712048, st_atime=2014/01/30-21:29:36, st_mtime=2012/06/20-17:15:22, st_ctime=2013/06/10-00:41:11}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf07000
mmap(NULL, 3239400, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2460fc000
mprotect(0x7ff24619f000, 2097152, PROT_NONE) = 0
mmap(0x7ff24639f000, 45056, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xa3000) = 0x7ff24639f000
mmap(0x7ff2463aa000, 429544, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2463aa000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdirac_encoder.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\257\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649668, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1152, st_size=585296, st_atime=2014/01/30-21:29:36, st_mtime=2012/02/07-09:36:41, st_ctime=2012/08/27-01:21:58}) = 0
mmap(NULL, 2686192, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff245e6c000
mprotect(0x7ff245ef7000, 2093056, PROT_NONE) = 0
mmap(0x7ff2460f6000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8a000) = 0x7ff2460f6000
mmap(0x7ff2460fb000, 3312, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2460fb000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdirac_decoder.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P \2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646768, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=832, st_size=419880, st_atime=2014/01/30-21:29:36, st_mtime=2012/02/07-09:36:41, st_ctime=2012/09/11-18:55:45}) = 0
mmap(NULL, 2519024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff245c05000
mprotect(0x7ff245c68000, 2097152, PROT_NONE) = 0
mmap(0x7ff245e68000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x63000) = 0x7ff245e68000
mmap(0x7ff245e6b000, 4080, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff245e6b000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libstdc++.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\264\5\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646604, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1920, st_size=975352, st_atime=2014/01/30-07:35:01, st_mtime=2014/01/15-16:57:43, st_ctime=2014/01/18-21:52:15}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf06000
mmap(NULL, 3154976, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff245902000
mprotect(0x7ff2459e7000, 2093056, PROT_NONE) = 0
mmap(0x7ff245be6000, 40960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe4000) = 0x7ff245be6000
mmap(0x7ff245bf0000, 82976, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff245bf0000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libschroedinger-1.0.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 M\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649724, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1648, st_size=835592, st_atime=2014/01/30-21:29:36, st_mtime=2012/04/26-08:16:43, st_ctime=2012/08/27-01:22:04}) = 0
mmap(NULL, 2933496, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff245635000
mprotect(0x7ff2456fe000, 2093056, PROT_NONE) = 0
mmap(0x7ff2458fd000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xc8000) = 0x7ff2458fd000
mmap(0x7ff245901000, 760, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff245901000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libvpx.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2005\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647527, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=3272, st_size=1670960, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/07-11:31:15, st_ctime=2014/01/18-21:54:55}) = 0
mmap(NULL, 4052768, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff245257000
mprotect(0x7ff2453ee000, 2093056, PROT_NONE) = 0
mmap(0x7ff2455ed000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x196000) = 0x7ff2455ed000
mmap(0x7ff2455ef000, 284448, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2455ef000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdvdnavmini.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P-\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646954, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=176, st_size=83880, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/12-00:42:58, st_ctime=2014/01/18-21:55:47}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf05000
mmap(NULL, 2179088, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff245042000
mprotect(0x7ff245055000, 2097152, PROT_NONE) = 0
mmap(0x7ff245255000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff245255000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libm.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0T\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=656043, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2040, st_size=1038752, st_atime=2014/01/29-22:10:01, st_mtime=2013/11/29-18:00:15, st_ctime=2014/01/11-22:06:37}) = 0
mmap(NULL, 3133768, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff244d44000
mprotect(0x7ff244e40000, 2097152, PROT_NONE) = 0
mmap(0x7ff245040000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xfc000) = 0x7ff245040000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libvorbisenc.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200:\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649548, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=5760, st_size=2943152, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/07-14:07:35, st_ctime=2012/08/27-01:20:58}) = 0
mmap(NULL, 5038240, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff244875000
mprotect(0x7ff244b28000, 2093056, PROT_NONE) = 0
mmap(0x7ff244d27000, 118784, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2b2000) = 0x7ff244d27000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libvorbis.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200:\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649552, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=368, st_size=183064, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/07-14:07:35, st_ctime=2012/08/27-01:20:58}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf04000
mmap(NULL, 2278152, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff244648000
mprotect(0x7ff244674000, 2093056, PROT_NONE) = 0
mmap(0x7ff244873000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2b000) = 0x7ff244873000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdirectfb-1.2.so.9", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 $\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649674, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1072, st_size=543736, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/20-14:51:04, st_ctime=2012/08/27-01:21:59}) = 0
mmap(NULL, 2641024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2443c3000
mprotect(0x7ff244444000, 2097152, PROT_NONE) = 0
mmap(0x7ff244644000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x81000) = 0x7ff244644000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXext.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`7\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647950, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=152, st_size=73384, st_atime=2014/01/30-21:29:36, st_mtime=2013/06/30-14:14:05, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2169144, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2441b1000
mprotect(0x7ff2441c2000, 2093056, PROT_NONE) = 0
mmap(0x7ff2443c1000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x10000) = 0x7ff2443c1000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libX11.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\337\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646815, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2528, st_size=1289808, st_atime=2014/01/30-21:29:31, st_mtime=2013/10/03-09:51:12, st_ctime=2014/01/11-22:06:37}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf03000
mmap(NULL, 3386848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff243e76000
mprotect(0x7ff243fab000, 2097152, PROT_NONE) = 0
mmap(0x7ff2441ab000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x135000) = 0x7ff2441ab000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXss.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\f\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646636, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10992, st_atime=2014/01/30-21:29:36, st_mtime=2012/04/22-09:42:33, st_ctime=2012/08/27-01:27:33}) = 0
mmap(NULL, 2106216, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff243c73000
mprotect(0x7ff243c75000, 2097152, PROT_NONE) = 0
mmap(0x7ff243e75000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff243e75000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXv.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\21\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647216, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18768, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-15:08:29, st_ctime=2014/01/22-21:57:01}) = 0
mmap(NULL, 2113960, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff243a6e000
mprotect(0x7ff243a72000, 2093056, PROT_NONE) = 0
mmap(0x7ff243c71000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff243c71000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXvMC.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\16\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648037, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14640, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/12-22:23:21, st_ctime=2013/08/18-01:01:03}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf02000
mmap(NULL, 2109832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24386a000
mprotect(0x7ff24386d000, 2093056, PROT_NONE) = 0
mmap(0x7ff243a6c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff243a6c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXvMCW.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\22\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648008, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18488, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/12-22:23:21, st_ctime=2013/08/18-01:01:03}) = 0
mmap(NULL, 2114096, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff243665000
mprotect(0x7ff243669000, 2093056, PROT_NONE) = 0
mmap(0x7ff243868000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff243868000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libvdpau.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\21\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646654, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14504, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/15-01:07:22, st_ctime=2013/08/18-01:01:01}) = 0
mmap(NULL, 2110048, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff243461000
mprotect(0x7ff243464000, 2093056, PROT_NONE) = 0
mmap(0x7ff243663000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff243663000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXinerama.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\v\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647244, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10408, st_atime=2014/01/30-21:29:36, st_mtime=2013/06/30-18:07:12, st_ctime=2013/07/03-00:19:46}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf01000
mmap(NULL, 2105672, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24325e000
mprotect(0x7ff243260000, 2093056, PROT_NONE) = 0
mmap(0x7ff24345f000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff24345f000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXxf86vm.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\17\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647099, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=22752, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/13-06:57:20, st_ctime=2013/08/18-00:59:50}) = 0
mmap(NULL, 2117992, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff243058000
mprotect(0x7ff24305d000, 2093056, PROT_NONE) = 0
mmap(0x7ff24325c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4000) = 0x7ff24325c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXxf86dga.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\31\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648706, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=27056, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/12-23:18:04, st_ctime=2013/08/18-01:01:03}) = 0
mmap(NULL, 2122376, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff242e51000
mprotect(0x7ff242e56000, 2097152, PROT_NONE) = 0
mmap(0x7ff243056000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff243056000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libaa.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@n\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647191, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=248, st_size=120224, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/12-10:01:57, st_ctime=2013/08/18-01:00:48}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf00000
mmap(NULL, 2222688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff242c32000
mprotect(0x7ff242c4d000, 2093056, PROT_NONE) = 0
mmap(0x7ff242e4c000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a000) = 0x7ff242e4c000
mmap(0x7ff242e4f000, 6752, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff242e4f000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libcaca.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649751, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1608, st_size=817640, st_atime=2014/01/30-21:29:36, st_mtime=2012/04/06-23:39:54, st_ctime=2012/08/27-01:22:06}) = 0
mmap(NULL, 838280, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24be33000
mmap(0x7ff24befa000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xc6000) = 0x7ff24befa000
mmap(0x7ff24befc000, 14984, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff24befc000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\256\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647486, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=888, st_size=448976, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/28-13:59:02, st_ctime=2014/01/11-22:06:37}) = 0
mmap(NULL, 2730840, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff242997000
mprotect(0x7ff242a02000, 2097152, PROT_NONE) = 0
mmap(0x7ff242c02000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6b000) = 0x7ff242c02000
mmap(0x7ff242c05000, 183128, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff242c05000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libGL.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240.\5\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=3043167, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2248, st_size=1145896, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/30-08:17:43, st_ctime=2014/01/18-21:56:15}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be32000
mmap(NULL, 3333936, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff242669000
mprotect(0x7ff242743000, 2093056, PROT_NONE) = 0
mmap(0x7ff242942000, 258048, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xd9000) = 0x7ff242942000
mmap(0x7ff242981000, 89904, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff242981000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libEGL.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360Y\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647108, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=288, st_size=139464, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/22-11:18:52, st_ctime=2013/10/27-22:58:15}) = 0
mmap(NULL, 2235944, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff242447000
mprotect(0x7ff242467000, 2097152, PROT_NONE) = 0
mmap(0x7ff242667000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x20000) = 0x7ff242667000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libpulse.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\303\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647074, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=608, st_size=304736, st_atime=2014/01/30-21:29:36, st_mtime=2013/09/12-12:13:07, st_ctime=2013/09/13-19:42:44}) = 0
mmap(NULL, 2398952, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2421fd000
mprotect(0x7ff242245000, 2097152, PROT_NONE) = 0
mmap(0x7ff242445000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x48000) = 0x7ff242445000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libjack.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\25\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647124, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=720, st_size=360480, st_atime=2014/01/30-21:29:36, st_mtime=2013/06/22-12:42:33, st_ctime=2013/06/30-22:29:27}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be31000
mmap(NULL, 2457480, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff241fa5000
mprotect(0x7ff241ffa000, 2093056, PROT_NONE) = 0
mmap(0x7ff2421f9000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x54000) = 0x7ff2421f9000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libfaac.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340#\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647487, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=168, st_size=77968, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/30-08:41:33, st_ctime=2013/06/10-00:41:10}) = 0
mmap(NULL, 2173160, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff241d92000
mprotect(0x7ff241da1000, 2097152, PROT_NONE) = 0
mmap(0x7ff241fa1000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xf000) = 0x7ff241fa1000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libx264.so.140", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200{\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648489, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1984, st_size=1011368, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/11-18:18:16, st_ctime=2013/12/14-02:45:29}) = 0
mmap(NULL, 3610720, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff241a20000
mprotect(0x7ff241b16000, 2093056, PROT_NONE) = 0
mmap(0x7ff241d15000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xf5000) = 0x7ff241d15000
mmap(0x7ff241d17000, 501856, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff241d17000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libmp3lame.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220o\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647518, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=568, st_size=285424, st_atime=2014/01/30-21:29:36, st_mtime=2013/03/05-08:49:46, st_ctime=2013/06/10-00:41:10}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be30000
mmap(NULL, 2570592, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2417ac000
mprotect(0x7ff2417f0000, 2097152, PROT_NONE) = 0
mmap(0x7ff2419f0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x44000) = 0x7ff2419f0000
mmap(0x7ff2419f2000, 186720, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2419f2000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/liblirc_client.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\23\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1367106, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=24224, st_atime=2014/01/30-21:29:36, st_mtime=2011/03/07-00:18:31, st_ctime=2012/08/27-01:22:28}) = 0
mmap(NULL, 2120384, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2415a6000
mprotect(0x7ff2415ac000, 2093056, PROT_NONE) = 0
mmap(0x7ff2417ab000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff2417ab000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\32\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=656004, st_mode=S_IFREG|0755, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=3416, st_size=1742520, st_atime=2014/01/29-22:10:01, st_mtime=2013/11/29-18:00:15, st_ctime=2014/01/11-22:06:37}) = 0
mmap(NULL, 3849280, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2411fa000
mprotect(0x7ff24139d000, 2093056, PROT_NONE) = 0
mmap(0x7ff24159c000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a2000) = 0x7ff24159c000
mmap(0x7ff2415a2000, 15424, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2415a2000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/tls/x86_64/libsamba-util.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/samba/tls/x86_64", 0x7fffb7532e90) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/tls/libsamba-util.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/samba/tls", 0x7fffb7532e90) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/x86_64/libsamba-util.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/samba/x86_64", 0x7fffb7532e90) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-util.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/samba", {st_dev=makedev(254, 0), st_ino=1679652, st_mode=S_IFDIR|0755, st_nlink=6, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=16384, st_atime=2013/10/27-23:01:20, st_mtime=2014/01/18-21:57:26, st_ctime=2014/01/18-21:57:26}) = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsamba-util.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\314\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648956, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=432, st_size=214496, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be2f000
mmap(NULL, 2310200, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240fc5000
mprotect(0x7ff240ff7000, 2097152, PROT_NONE) = 0
mmap(0x7ff2411f7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x32000) = 0x7ff2411f7000
mmap(0x7ff2411f9000, 56, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2411f9000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/liblibsmb.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\0\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347379, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=824, st_size=416632, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2511688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240d5f000
mprotect(0x7ff240dc2000, 2097152, PROT_NONE) = 0
mmap(0x7ff240fc2000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x63000) = 0x7ff240fc2000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libmsrpc3.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`H\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347380, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=168, st_size=81168, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2176232, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240b4b000
mprotect(0x7ff240b5e000, 2093056, PROT_NONE) = 0
mmap(0x7ff240d5d000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x12000) = 0x7ff240d5d000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/liblibcli_lsa3.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\21\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347377, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14544, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be2e000
mmap(NULL, 2109672, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240947000
mprotect(0x7ff24094a000, 2093056, PROT_NONE) = 0
mmap(0x7ff240b49000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff240b49000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-security.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\205\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347394, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=248, st_size=122848, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2217896, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240729000
mprotect(0x7ff240745000, 2093056, PROT_NONE) = 0
mmap(0x7ff240944000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b000) = 0x7ff240944000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/liberrors.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240D\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347277, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1072, st_size=542928, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2638088, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2404a4000
mprotect(0x7ff240510000, 2097152, PROT_NONE) = 0
mmap(0x7ff240710000, 102400, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6c000) = 0x7ff240710000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsmbconf.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsmbconf.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\t\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648960, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1144, st_size=577608, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be2d000
mmap(NULL, 2675592, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240216000
mprotect(0x7ff240298000, 2097152, PROT_NONE) = 0
mmap(0x7ff240498000, 45056, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x82000) = 0x7ff240498000
mmap(0x7ff2404a3000, 904, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff2404a3000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libndr.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libndr.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\\\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648947, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=176, st_size=85184, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2180240, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff240001000
mprotect(0x7ff240015000, 2093056, PROT_NONE) = 0
mmap(0x7ff240214000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff240214000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libcli_smb_common.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\\\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347155, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=264, st_size=130576, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2225664, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23fde1000
mprotect(0x7ff23fe00000, 2093056, PROT_NONE) = 0
mmap(0x7ff23ffff000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e000) = 0x7ff23ffff000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libgse.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240~\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347286, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=336, st_size=164504, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be2c000
mmap(NULL, 2259560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23fbb9000
mprotect(0x7ff23fbdf000, 2097152, PROT_NONE) = 0
mmap(0x7ff23fddf000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x26000) = 0x7ff23fddf000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libutil_cmdline.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\24\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347413, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14552, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2109680, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23f9b5000
mprotect(0x7ff23f9b8000, 2093056, PROT_NONE) = 0
mmap(0x7ff23fbb7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff23fbb7000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libndr-standard.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libndr-standard.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`(\4\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648946, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=6344, st_size=3240520, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 5335576, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23f49e000
mprotect(0x7ff23f7a5000, 2097152, PROT_NONE) = 0
mmap(0x7ff23f9a5000, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x307000) = 0x7ff23f9a5000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libdcerpc-samba.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\276\3\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347269, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=3168, st_size=1614768, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be2b000
mmap(NULL, 3709896, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23f114000
mprotect(0x7ff23f29a000, 2097152, PROT_NONE) = 0
mmap(0x7ff23f49a000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x186000) = 0x7ff23f49a000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsmbregistry.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20t\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347409, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=256, st_size=122888, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2217968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23eef6000
mprotect(0x7ff23ef12000, 2093056, PROT_NONE) = 0
mmap(0x7ff23f111000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b000) = 0x7ff23f111000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsecrets3.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\00004\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347399, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=88, st_size=43928, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2139072, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23eceb000
mprotect(0x7ff23ecf5000, 2093056, PROT_NONE) = 0
mmap(0x7ff23eef4000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9000) = 0x7ff23eef4000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libtalloc.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libtalloc.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\37\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648804, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=96, st_size=47504, st_atime=2014/01/30-21:29:36, st_mtime=2013/09/14-14:24:31, st_ctime=2013/10/27-23:01:33}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be2a000
mmap(NULL, 2142704, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23eadf000
mprotect(0x7ff23eaea000, 2093056, PROT_NONE) = 0
mmap(0x7ff23ece9000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xa000) = 0x7ff23ece9000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libbsd.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libbsd.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360+\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328761, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=120, st_size=56144, st_atime=2014/01/30-21:29:36, st_mtime=2013/07/14-14:37:11, st_ctime=2013/07/30-00:57:48}) = 0
mmap(NULL, 2155432, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23e8d0000
mprotect(0x7ff23e8dd000, 2093056, PROT_NONE) = 0
mmap(0x7ff23eadc000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xc000) = 0x7ff23eadc000
mmap(0x7ff23eade000, 936, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23eade000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/liblcms.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0pv\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647366, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=448, st_size=225216, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/08-18:06:59, st_ctime=2013/12/14-02:44:42}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be29000
mmap(NULL, 2331520, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23e696000
mprotect(0x7ff23e6cc000, 2093056, PROT_NONE) = 0
mmap(0x7ff23e8cb000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x35000) = 0x7ff23e8cb000
mmap(0x7ff23e8cd000, 9088, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23e8cd000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/librt.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20#\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=655723, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=64, st_size=31752, st_atime=2014/01/30-00:00:01, st_mtime=2013/11/29-18:00:15, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2128888, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23e48e000
mprotect(0x7ff23e495000, 2093056, PROT_NONE) = 0
mmap(0x7ff23e694000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6000) = 0x7ff23e694000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxml2.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\350\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646877, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2872, st_size=1465592, st_atime=2014/01/30-07:53:43, st_mtime=2013/08/05-05:22:52, st_ctime=2013/08/11-11:23:22}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be28000
mmap(NULL, 3566008, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23e127000
mprotect(0x7ff23e284000, 2093056, PROT_NONE) = 0
mmap(0x7ff23e483000, 40960, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15c000) = 0x7ff23e483000
mmap(0x7ff23e48d000, 2488, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23e48d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libexpat.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220;\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328880, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=344, st_size=169960, st_atime=2014/01/30-21:29:36, st_mtime=2013/07/07-18:10:44, st_ctime=2013/07/30-00:56:37}) = 0
mmap(NULL, 2265224, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23defd000
mprotect(0x7ff23df24000, 2097152, PROT_NONE) = 0
mmap(0x7ff23e124000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x27000) = 0x7ff23e124000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libgcc_s.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260*\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328782, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=184, st_size=89216, st_atime=2014/01/30-07:35:01, st_mtime=2014/01/15-16:53:17, st_ctime=2014/01/18-21:52:03}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be27000
mmap(NULL, 2184800, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23dce7000
mprotect(0x7ff23dcfc000, 2097152, PROT_NONE) = 0
mmap(0x7ff23defc000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x15000) = 0x7ff23defc000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgnutls.so.26", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\217\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646745, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1544, st_size=785544, st_atime=2014/01/30-00:10:45, st_mtime=2013/10/06-17:48:21, st_ctime=2013/10/27-22:58:46}) = 0
mmap(NULL, 2882736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23da27000
mprotect(0x7ff23dae0000, 2093056, PROT_NONE) = 0
mmap(0x7ff23dcdf000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xb8000) = 0x7ff23dcdf000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libgcrypt.so.11", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\177\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=329007, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1032, st_size=520608, st_atime=2014/01/29-22:10:45, st_mtime=2013/12/22-18:44:53, st_ctime=2014/01/18-21:53:48}) = 0
mmap(NULL, 2616960, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23d7a8000
mprotect(0x7ff23d823000, 2097152, PROT_NONE) = 0
mmap(0x7ff23da23000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7b000) = 0x7ff23da23000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be26000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/liborc-0.4.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\343\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647887, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1080, st_size=548080, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/26-09:09:20, st_ctime=2013/09/08-20:19:26}) = 0
mmap(NULL, 2643672, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23d522000
mprotect(0x7ff23d5a2000, 2093056, PROT_NONE) = 0
mmap(0x7ff23d7a1000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7f000) = 0x7ff23d7a1000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdirect-1.2.so.9", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0S\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649672, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=200, st_size=95568, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/20-14:51:04, st_ctime=2012/08/27-01:21:59}) = 0
mmap(NULL, 2193192, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23d30a000
mprotect(0x7ff23d321000, 2093056, PROT_NONE) = 0
mmap(0x7ff23d520000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) = 0x7ff23d520000
mmap(0x7ff23d521000, 1832, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23d521000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libfusion-1.2.so.9", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p4\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649673, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=80, st_size=40120, st_atime=2014/01/30-21:29:36, st_mtime=2012/05/20-14:51:04, st_ctime=2012/08/27-01:21:59}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be25000
mmap(NULL, 2135264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23d100000
mprotect(0x7ff23d109000, 2097152, PROT_NONE) = 0
mmap(0x7ff23d309000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9000) = 0x7ff23d309000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxcb.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\234\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647642, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=256, st_size=125728, st_atime=2014/01/30-21:29:31, st_mtime=2014/01/04-14:54:15, st_ctime=2014/01/18-21:57:28}) = 0
mmap(NULL, 2221064, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23cee1000
mprotect(0x7ff23ceff000, 2093056, PROT_NONE) = 0
mmap(0x7ff23d0fe000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1d000) = 0x7ff23d0fe000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libslang.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\207\4\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328789, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2440, st_size=1243904, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/07-23:12:50, st_ctime=2013/12/14-02:45:06}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be24000
mmap(NULL, 3748280, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23cb4d000
mprotect(0x7ff23cc60000, 2097152, PROT_NONE) = 0
mmap(0x7ff23ce60000, 118784, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x113000) = 0x7ff23ce60000
mmap(0x7ff23ce7d000, 405944, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23ce7d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgpm.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0!\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646880, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=23680, st_atime=2014/01/30-21:29:36, st_mtime=2013/06/23-16:01:15, st_ctime=2013/06/30-22:29:04}) = 0
mmap(NULL, 2119992, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23c947000
mprotect(0x7ff23c94c000, 2097152, PROT_NONE) = 0
mmap(0x7ff23cb4c000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff23cb4c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libncursesw.so.5", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\205\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328786, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=432, st_size=217016, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-19:26:42, st_ctime=2014/01/22-21:56:22}) = 0
mmap(NULL, 2312680, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23c712000
mprotect(0x7ff23c746000, 2093056, PROT_NONE) = 0
mmap(0x7ff23c945000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x33000) = 0x7ff23c945000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libpulse-simple.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\25\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647078, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18784, st_atime=2014/01/30-21:29:36, st_mtime=2013/09/12-12:13:07, st_ctime=2013/09/13-19:42:44}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be23000
mmap(NULL, 2113936, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23c50d000
mprotect(0x7ff23c510000, 2097152, PROT_NONE) = 0
mmap(0x7ff23c710000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff23c710000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libts-0.0.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\17\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647084, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10376, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-09:26:26, st_ctime=2014/01/22-21:56:59}) = 0
mmap(NULL, 2106688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23c30a000
mprotect(0x7ff23c30c000, 2093056, PROT_NONE) = 0
mmap(0x7ff23c50b000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff23c50b000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/tls/libnvidia-tls.so.319.82", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\t\0\0\0\0\0\0"..., 832) = 832
lseek(3, 10440, SEEK_SET)               = 10440
read(3, "\4\0\0\0\20\0\0\0\1\0\0\0GNU\0\0\0\0\0\2\0\0\0\3\0\0\0c\0\0\0", 32) = 32
fstat(3, {st_dev=makedev(254, 0), st_ino=3014659, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=12720, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/30-08:20:33, st_ctime=2014/01/18-21:56:15}) = 0
mmap(NULL, 2108992, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23c107000
mprotect(0x7ff23c10a000, 2093056, PROT_NONE) = 0
mmap(0x7ff23c309000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff23c309000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libnvidia-glcore.so.319.82", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\v\231\0\0\0\0\0"..., 832) = 832
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be22000
fstat(3, {st_dev=makedev(254, 0), st_ino=1648756, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=72280, st_size=36965680, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/30-08:16:57, st_ctime=2014/01/18-21:56:15}) = 0
mmap(NULL, 39165792, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff239bad000
mprotect(0x7ff23b5f7000, 2093056, PROT_NONE) = 0
mmap(0x7ff23b7f6000, 9404416, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a49000) = 0x7ff23b7f6000
mmap(0x7ff23c0ee000, 102240, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23c0ee000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libX11-xcb.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\5\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646910, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=16, st_size=5992, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/03-09:51:12, st_ctime=2013/10/27-22:56:38}) = 0
mmap(NULL, 2101304, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2399ab000
mprotect(0x7ff2399ac000, 2093056, PROT_NONE) = 0
mmap(0x7ff239bab000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0) = 0x7ff239bab000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxcb-dri2.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\30\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647661, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18528, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/04-14:54:19, st_ctime=2014/01/18-21:57:29}) = 0
mmap(NULL, 2113656, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2397a6000
mprotect(0x7ff2397a9000, 2097152, PROT_NONE) = 0
mmap(0x7ff2399a9000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff2399a9000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxcb-xfixes.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260'\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647683, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=26704, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/04-14:54:18, st_ctime=2014/01/18-21:57:31}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be21000
mmap(NULL, 2121832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23959f000
mprotect(0x7ff2395a4000, 2097152, PROT_NONE) = 0
mmap(0x7ff2397a4000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff2397a4000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxcb-render.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2205\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647673, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=72, st_size=34976, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/04-14:54:17, st_ctime=2014/01/18-21:57:30}) = 0
mmap(NULL, 2130104, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff239396000
mprotect(0x7ff23939e000, 2093056, PROT_NONE) = 0
mmap(0x7ff23959d000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7000) = 0x7ff23959d000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libxcb-shape.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\17\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646761, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14416, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/04-14:54:17, st_ctime=2014/01/18-21:57:30}) = 0
mmap(NULL, 2109544, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff239192000
mprotect(0x7ff239194000, 2097152, PROT_NONE) = 0
mmap(0x7ff239394000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff239394000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libwayland-client.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000O\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648923, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=120, st_size=56688, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-10:36:56, st_ctime=2014/01/22-21:57:00}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be20000
mmap(NULL, 2151848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff238f84000
mprotect(0x7ff238f90000, 2093056, PROT_NONE) = 0
mmap(0x7ff23918f000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xb000) = 0x7ff23918f000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libwayland-server.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240a\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647043, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=69288, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-10:36:57, st_ctime=2014/01/22-21:57:00}) = 0
mmap(NULL, 2164648, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff238d73000
mprotect(0x7ff238d82000, 2093056, PROT_NONE) = 0
mmap(0x7ff238f81000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe000) = 0x7ff238f81000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgbm.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P!\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647097, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=27392, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/22-11:18:52, st_ctime=2013/10/27-22:58:15}) = 0
mmap(NULL, 2122720, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff238b6c000
mprotect(0x7ff238b72000, 2093056, PROT_NONE) = 0
mmap(0x7ff238d71000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff238d71000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libudev.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2604\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=163890, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=152, st_size=71568, st_atime=2014/01/30-07:53:43, st_mtime=2013/12/31-18:54:05, st_ctime=2014/01/18-21:54:25}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be1f000
mmap(NULL, 2168912, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23895a000
mprotect(0x7ff23896a000, 2097152, PROT_NONE) = 0
mmap(0x7ff238b6a000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x10000) = 0x7ff238b6a000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdrm.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2602\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646780, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=96, st_size=47568, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/20-13:49:48, st_ctime=2014/01/22-21:56:42}) = 0
mmap(NULL, 2145200, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23874e000
mprotect(0x7ff238759000, 2093056, PROT_NONE) = 0
mmap(0x7ff238958000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xa000) = 0x7ff238958000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/tls/x86_64/libjson-c.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/pulseaudio/tls/x86_64", 0x7fffb75325f0) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/pulseaudio/tls/libjson-c.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/pulseaudio/tls", 0x7fffb75325f0) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/pulseaudio/x86_64/libjson-c.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/pulseaudio/x86_64", 0x7fffb75325f0) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libjson-c.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
stat("/usr/lib/x86_64-linux-gnu/pulseaudio", {st_dev=makedev(254, 0), st_ino=1729471, st_mode=S_IFDIR|0755, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=4096, st_atime=2012/08/27-01:16:42, st_mtime=2013/09/13-19:42:44, st_ctime=2013/09/13-19:42:44}) = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libjson-c.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000/\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328820, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=88, st_size=43840, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/27-13:00:16, st_ctime=2013/09/08-20:20:32}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be1e000
mmap(NULL, 2138984, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff238543000
mprotect(0x7ff23854d000, 2093056, PROT_NONE) = 0
mmap(0x7ff23874c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9000) = 0x7ff23874c000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libpulsecommon-4.0.so", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000?\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1728733, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=872, st_size=441760, st_atime=2014/01/30-21:29:36, st_mtime=2013/09/12-12:13:07, st_ctime=2013/09/13-19:42:44}) = 0
mmap(NULL, 2537560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2382d7000
mprotect(0x7ff238341000, 2093056, PROT_NONE) = 0
mmap(0x7ff238540000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x69000) = 0x7ff238540000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libdbus-1.so.3", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libdbus-1.so.3", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 y\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328949, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=568, st_size=286600, st_atime=2014/01/29-22:00:01, st_mtime=2014/01/20-16:13:28, st_ctime=2014/01/22-21:56:41}) = 0
mmap(NULL, 2382264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff238091000
mprotect(0x7ff2380d6000, 2093056, PROT_NONE) = 0
mmap(0x7ff2382d5000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x44000) = 0x7ff2382d5000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libcap.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libcap.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\26\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328846, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=17112, st_atime=2014/01/29-22:35:01, st_mtime=2012/08/11-14:23:01, st_ctime=2013/06/10-01:07:37}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be1d000
mmap(NULL, 2112384, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff237e8d000
mprotect(0x7ff237e91000, 2093056, PROT_NONE) = 0
mmap(0x7ff238090000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff238090000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libtevent.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libtevent.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libtevent.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`2\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647354, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=112, st_size=51944, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/11-17:18:35, st_ctime=2013/08/18-01:01:00}) = 0
mmap(NULL, 2147040, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff237c80000
mprotect(0x7ff237c8c000, 2093056, PROT_NONE) = 0
mmap(0x7ff237e8b000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xb000) = 0x7ff237e8b000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libwbclient.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libwbclient.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libwbclient.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\37\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646835, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=88, st_size=43360, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:29, st_ctime=2014/01/18-21:57:20}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be1c000
mmap(NULL, 2145552, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff237a74000
mprotect(0x7ff237a7e000, 2093056, PROT_NONE) = 0
mmap(0x7ff237c7d000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9000) = 0x7ff237c7d000
mmap(0x7ff237c7f000, 3344, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff237c7f000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-credentials.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-credentials.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsamba-credentials.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0PT\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648952, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=69080, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2164240, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff237863000
mprotect(0x7ff237873000, 2093056, PROT_NONE) = 0
mmap(0x7ff237a72000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xf000) = 0x7ff237a72000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libndr-samba.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\335\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347381, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1840, st_size=934800, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 3029856, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23757f000
mprotect(0x7ff23765d000, 2097152, PROT_NONE) = 0
mmap(0x7ff23785d000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xde000) = 0x7ff23785d000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libcli_cldap.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0,\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347150, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=64, st_size=31496, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be1b000
mmap(NULL, 2126552, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff237377000
mprotect(0x7ff23737e000, 2093056, PROT_NONE) = 0
mmap(0x7ff23757d000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6000) = 0x7ff23757d000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libcliauth.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p=\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347166, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=152, st_size=72696, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2167872, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff237165000
mprotect(0x7ff237176000, 2093056, PROT_NONE) = 0
mmap(0x7ff237375000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x10000) = 0x7ff237375000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libkrb5samba.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P8\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347329, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=80, st_size=39944, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2135104, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff236f5b000
mprotect(0x7ff236f64000, 2093056, PROT_NONE) = 0
mmap(0x7ff237163000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8000) = 0x7ff237163000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-sockets.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260N\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347395, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=200, st_size=97584, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be1a000
mmap(NULL, 2192640, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff236d43000
mprotect(0x7ff236d59000, 2097152, PROT_NONE) = 0
mmap(0x7ff236f59000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) = 0x7ff236f59000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libgensec.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libgensec.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgensec.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320v\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648940, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=296, st_size=143368, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2238472, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff236b20000
mprotect(0x7ff236b41000, 2097152, PROT_NONE) = 0
mmap(0x7ff236d41000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x21000) = 0x7ff236d41000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libasn1util.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\34\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=345832, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=22920, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2118048, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23691a000
mprotect(0x7ff23691f000, 2093056, PROT_NONE) = 0
mmap(0x7ff236b1e000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4000) = 0x7ff236b1e000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-hostconfig.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-hostconfig.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsamba-hostconfig.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\305\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648953, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=448, st_size=221824, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be19000
mmap(NULL, 2316896, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2366e4000
mprotect(0x7ff236712000, 2097152, PROT_NONE) = 0
mmap(0x7ff236912000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2e000) = 0x7ff236912000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libndr-nbt.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libndr-nbt.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libndr-nbt.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`Q\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648944, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=176, st_size=85496, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2180552, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2364cf000
mprotect(0x7ff2364e3000, 2093056, PROT_NONE) = 0
mmap(0x7ff2366e2000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff2366e2000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libtevent-util.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libtevent-util.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libtevent-util.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\16\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648964, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10400, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2105528, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2362cc000
mprotect(0x7ff2362ce000, 2093056, PROT_NONE) = 0
mmap(0x7ff2364cd000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff2364cd000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsmb_transport.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \24\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347403, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18728, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be18000
mmap(NULL, 2113856, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2360c7000
mprotect(0x7ff2360cb000, 2093056, PROT_NONE) = 0
mmap(0x7ff2362ca000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff2362ca000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamba3-util.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240,\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347396, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=88, st_size=43704, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2138864, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff235ebc000
mprotect(0x7ff235ec5000, 2097152, PROT_NONE) = 0
mmap(0x7ff2360c5000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x9000) = 0x7ff2360c5000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libCHARSET3.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\17\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=344176, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10424, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2105552, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff235cb9000
mprotect(0x7ff235cbb000, 2093056, PROT_NONE) = 0
mmap(0x7ff235eba000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff235eba000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libcom_err.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libcom_err.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libcom_err.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\25\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=393219, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14640, st_atime=2014/01/30-06:38:12, st_mtime=2013/12/31-00:28:48, st_ctime=2014/01/18-21:53:03}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be17000
mmap(NULL, 2109960, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff235ab5000
mprotect(0x7ff235ab8000, 2093056, PROT_NONE) = 0
mmap(0x7ff235cb7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff235cb7000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libdcerpc-binding.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libdcerpc-binding.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libdcerpc-binding.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300q\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648927, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=216, st_size=102416, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2197472, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23589c000
mprotect(0x7ff2358b4000, 2093056, PROT_NONE) = 0
mmap(0x7ff235ab3000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x17000) = 0x7ff235ab3000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libinterfaces.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\n\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347327, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10360, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be16000
mmap(NULL, 2105488, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff235699000
mprotect(0x7ff23569b000, 2093056, PROT_NONE) = 0
mmap(0x7ff23589a000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff23589a000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libdbwrap.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P2\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347250, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=112, st_size=52128, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2147288, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23548c000
mprotect(0x7ff235498000, 2093056, PROT_NONE) = 0
mmap(0x7ff235697000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xb000) = 0x7ff235697000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libutil_tdb.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\24\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347416, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14624, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2109752, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff235288000
mprotect(0x7ff23528b000, 2093056, PROT_NONE) = 0
mmap(0x7ff23548a000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff23548a000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libutil_reg.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\n\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347414, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10368, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be15000
mmap(NULL, 2105424, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff235085000
mprotect(0x7ff235086000, 2097152, PROT_NONE) = 0
mmap(0x7ff235286000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff235286000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsmbd_shim.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\10\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347406, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=16, st_size=6112, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2101416, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff234e83000
mprotect(0x7ff234e84000, 2093056, PROT_NONE) = 0
mmap(0x7ff235083000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0) = 0x7ff235083000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libutil_setid.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\t\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347415, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=16, st_size=6120, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2101320, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff234c81000
mprotect(0x7ff234c82000, 2093056, PROT_NONE) = 0
mmap(0x7ff234e81000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0) = 0x7ff234e81000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libtdb-wrap.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\f\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347410, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10408, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be14000
mmap(NULL, 2105544, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff234a7e000
mprotect(0x7ff234a80000, 2093056, PROT_NONE) = 0
mmap(0x7ff234c7f000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff234c7f000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libserver-role.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\10\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347400, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=16, st_size=6272, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2101328, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23487c000
mprotect(0x7ff23487d000, 2093056, PROT_NONE) = 0
mmap(0x7ff234a7c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0) = 0x7ff234a7c000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libnsl.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libnsl.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libnsl.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`A\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=656045, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=184, st_size=89104, st_atime=2014/01/30-00:05:02, st_mtime=2013/11/29-18:00:15, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2194072, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff234664000
mprotect(0x7ff234679000, 2093056, PROT_NONE) = 0
mmap(0x7ff234878000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14000) = 0x7ff234878000
mmap(0x7ff23487a000, 6808, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23487a000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libtdb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libtdb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libtdb.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240%\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646916, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=152, st_size=72200, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/11-15:47:20, st_ctime=2013/08/18-01:01:00}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be13000
mmap(NULL, 2167312, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff234452000
mprotect(0x7ff234463000, 2093056, PROT_NONE) = 0
mmap(0x7ff234662000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x10000) = 0x7ff234662000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/liblber-2.4.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/liblber-2.4.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/liblber-2.4.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@5\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646600, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=128, st_size=59576, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/30-03:33:25, st_ctime=2013/09/08-20:18:53}) = 0
mmap(NULL, 2154920, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff234243000
mprotect(0x7ff234251000, 2093056, PROT_NONE) = 0
mmap(0x7ff234450000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xd000) = 0x7ff234450000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libldap_r-2.4.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libldap_r-2.4.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\361\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646671, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=640, st_size=323024, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/30-03:33:25, st_ctime=2013/09/08-20:18:53}) = 0
mmap(NULL, 2427560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff233ff2000
mprotect(0x7ff23403e000, 2097152, PROT_NONE) = 0
mmap(0x7ff23423e000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4c000) = 0x7ff23423e000
mmap(0x7ff234241000, 6824, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff234241000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be12000
open("/usr/lib/x86_64-linux-gnu/samba/libaddns.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20,\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=345814, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=112, st_size=52064, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2147136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff233de5000
mprotect(0x7ff233df0000, 2097152, PROT_NONE) = 0
mmap(0x7ff233ff0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xb000) = 0x7ff233ff0000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libauthkrb5.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\\\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347138, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=200, st_size=98056, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2193112, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff233bcd000
mprotect(0x7ff233be3000, 2097152, PROT_NONE) = 0
mmap(0x7ff233de3000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) = 0x7ff233de3000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libcli-nbt.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300)\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347148, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=80, st_size=39648, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be11000
mmap(NULL, 2134776, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2339c3000
mprotect(0x7ff2339cc000, 2093056, PROT_NONE) = 0
mmap(0x7ff233bcb000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8000) = 0x7ff233bcb000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libkrb5.so.26", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libkrb5.so.26", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libkrb5.so.26", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\5\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649163, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1128, st_size=572296, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:37, st_ctime=2013/12/14-02:46:22}) = 0
mmap(NULL, 2670256, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff233737000
mprotect(0x7ff2337bd000, 2093056, PROT_NONE) = 0
mmap(0x7ff2339bc000, 28672, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x85000) = 0x7ff2339bc000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libgssapi.so.3", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libgssapi.so.3", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libgssapi.so.3", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\342\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649199, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=504, st_size=252352, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:37, st_ctime=2013/12/14-02:46:22}) = 0
mmap(NULL, 2347832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2334f9000
mprotect(0x7ff233533000, 2097152, PROT_NONE) = 0
mmap(0x7ff233733000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3a000) = 0x7ff233733000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be10000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/liblzma.so.5", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360,\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328801, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=288, st_size=141784, st_atime=2014/01/30-07:30:01, st_mtime=2012/11/18-20:30:36, st_ctime=2013/01/20-14:46:38}) = 0
mmap(NULL, 2236904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2332d6000
mprotect(0x7ff2332f8000, 2093056, PROT_NONE) = 0
mmap(0x7ff2334f7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x21000) = 0x7ff2334f7000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libtasn1.so.3", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\37\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646829, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=144, st_size=68072, st_atime=2014/01/29-23:40:45, st_mtime=2013/05/18-12:54:18, st_ctime=2013/06/09-22:44:21}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be0f000
mmap(NULL, 2163656, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2330c5000
mprotect(0x7ff2330d5000, 2093056, PROT_NONE) = 0
mmap(0x7ff2332d4000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xf000) = 0x7ff2332d4000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libp11-kit.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\325\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646979, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=536, st_size=268560, st_atime=2014/01/29-22:00:01, st_mtime=2014/01/18-20:17:24, st_ctime=2014/01/22-21:56:40}) = 0
mmap(NULL, 2364688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff232e83000
mprotect(0x7ff232ebe000, 2093056, PROT_NONE) = 0
mmap(0x7ff2330bd000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3a000) = 0x7ff2330bd000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libgpg-error.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\t\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=330532, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18320, st_atime=2014/01/29-23:40:45, st_mtime=2013/09/05-22:29:24, st_ctime=2013/09/08-20:17:36}) = 0
mmap(NULL, 2113656, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff232c7e000
mprotect(0x7ff232c82000, 2093056, PROT_NONE) = 0
mmap(0x7ff232e81000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff232e81000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXau.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\20\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646891, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14544, st_atime=2014/01/30-21:29:31, st_mtime=2013/06/14-20:26:14, st_ctime=2013/06/30-22:24:43}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be0e000
mmap(NULL, 2109744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff232a7a000
mprotect(0x7ff232a7d000, 2093056, PROT_NONE) = 0
mmap(0x7ff232c7c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff232c7c000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXdmcp.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\23\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649164, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=20648, st_atime=2014/01/30-21:29:31, st_mtime=2012/04/14-18:38:25, st_ctime=2012/08/27-01:10:55}) = 0
mmap(NULL, 2115840, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff232875000
mprotect(0x7ff23287a000, 2093056, PROT_NONE) = 0
mmap(0x7ff232a79000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4000) = 0x7ff232a79000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libffi.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\30\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646616, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=64, st_size=31048, st_atime=2014/01/29-22:00:01, st_mtime=2014/01/21-17:26:02, st_ctime=2014/01/22-21:56:40}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be0d000
mmap(NULL, 2127400, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23266d000
mprotect(0x7ff232674000, 2093056, PROT_NONE) = 0
mmap(0x7ff232873000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6000) = 0x7ff232873000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libglapi.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\215\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646980, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=304, st_size=149864, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/22-11:18:52, st_ctime=2013/10/27-22:58:14}) = 0
mmap(NULL, 2251224, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff232447000
mprotect(0x7ff232468000, 2097152, PROT_NONE) = 0
mmap(0x7ff232668000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x21000) = 0x7ff232668000
mmap(0x7ff23266c000, 2520, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff23266c000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libICE.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libICE.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260R\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647514, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=200, st_size=96320, st_atime=2014/01/30-21:29:36, st_mtime=2012/04/09-20:11:19, st_ctime=2012/08/27-01:14:49}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be0c000
mmap(NULL, 2205984, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23222c000
mprotect(0x7ff232243000, 2093056, PROT_NONE) = 0
mmap(0x7ff232442000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x16000) = 0x7ff232442000
mmap(0x7ff232444000, 10528, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff232444000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libSM.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libSM.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\34\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647521, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=64, st_size=30096, st_atime=2014/01/30-21:29:36, st_mtime=2012/04/09-20:19:36, st_ctime=2012/08/27-01:15:12}) = 0
mmap(NULL, 2125312, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff232025000
mprotect(0x7ff23202c000, 2093056, PROT_NONE) = 0
mmap(0x7ff23222b000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6000) = 0x7ff23222b000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libXtst.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXtst.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\24\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647238, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=48, st_size=22880, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/12-20:36:57, st_ctime=2013/08/18-00:59:02}) = 0
mmap(NULL, 2118200, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff231e1f000
mprotect(0x7ff231e24000, 2093056, PROT_NONE) = 0
mmap(0x7ff232023000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4000) = 0x7ff232023000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libwrap.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libwrap.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\3000\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=163886, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=80, st_size=40624, st_atime=2014/01/30-03:37:00, st_mtime=2014/01/12-20:12:18, st_ctime=2014/01/18-21:54:24}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be0b000
mmap(NULL, 2138176, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff231c14000
mprotect(0x7ff231c1d000, 2093056, PROT_NONE) = 0
mmap(0x7ff231e1c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8000) = 0x7ff231e1c000
mmap(0x7ff231e1e000, 64, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff231e1e000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libsndfile.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsndfile.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260a\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647631, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=816, st_size=409728, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/27-21:56:30, st_ctime=2014/01/22-21:56:59}) = 0
mmap(NULL, 2522640, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2319ac000
mprotect(0x7ff231a0d000, 2097152, PROT_NONE) = 0
mmap(0x7ff231c0d000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x61000) = 0x7ff231c0d000
mmap(0x7ff231c10000, 15888, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff231c10000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libasyncns.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libasyncns.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\22\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649625, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=19536, st_atime=2014/01/30-21:29:36, st_mtime=2011/08/10-00:05:03, st_ctime=2012/08/27-01:21:41}) = 0
mmap(NULL, 2114832, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2317a7000
mprotect(0x7ff2317ac000, 2093056, PROT_NONE) = 0
mmap(0x7ff2319ab000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4000) = 0x7ff2319ab000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be0a000
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libattr.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libattr.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\24\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328984, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=18672, st_atime=2014/01/30-00:00:01, st_mtime=2013/05/20-14:11:42, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2113896, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff2315a2000
mprotect(0x7ff2315a6000, 2093056, PROT_NONE) = 0
mmap(0x7ff2317a5000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff2317a5000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libwinbind-client.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\16\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=344134, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14560, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:29, st_ctime=2014/01/18-21:57:20}) = 0
mmap(NULL, 2109696, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23139e000
mprotect(0x7ff2313a0000, 2097152, PROT_NONE) = 0
mmap(0x7ff2315a0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff2315a0000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamdb-common.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`j\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347398, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=248, st_size=122640, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be09000
mmap(NULL, 2217728, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff231180000
mprotect(0x7ff23119c000, 2097152, PROT_NONE) = 0
mmap(0x7ff23139c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1c000) = 0x7ff23139c000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libldbsamba.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\237\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347333, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=352, st_size=172328, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2267400, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230f56000
mprotect(0x7ff230f7d000, 2097152, PROT_NONE) = 0
mmap(0x7ff23117d000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x27000) = 0x7ff23117d000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libldb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libldb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libldb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libldb.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p|\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646924, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=368, st_size=184232, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/11-17:52:03, st_ctime=2013/10/27-23:01:34}) = 0
mmap(NULL, 2279352, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230d29000
mprotect(0x7ff230d55000, 2093056, PROT_NONE) = 0
mmap(0x7ff230f54000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2b000) = 0x7ff230f54000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be08000
open("/usr/lib/x86_64-linux-gnu/samba/libcli-ldap-common.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\33\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347144, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=27088, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2122216, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230b22000
mprotect(0x7ff230b28000, 2093056, PROT_NONE) = 0
mmap(0x7ff230d27000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff230d27000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libasn1.so.8", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libasn1.so.8", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libasn1.so.8", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libasn1.so.8", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0%\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647499, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1376, st_size=697456, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:37, st_ctime=2013/12/14-02:45:26}) = 0
mmap(NULL, 2792560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230878000
mprotect(0x7ff23091d000, 2097152, PROT_NONE) = 0
mmap(0x7ff230b1d000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xa5000) = 0x7ff230b1d000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamba-modules.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\r\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347392, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=24, st_size=10416, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:23, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be07000
mmap(NULL, 2105544, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230675000
mprotect(0x7ff230677000, 2093056, PROT_NONE) = 0
mmap(0x7ff230876000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7ff230876000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsamdb.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsamdb.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsamdb.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsamdb.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000Y\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648957, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=184, st_size=86128, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2181264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230460000
mprotect(0x7ff230474000, 2093056, PROT_NONE) = 0
mmap(0x7ff230673000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff230673000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libutil_ntdb.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\22\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347419, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14600, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:22, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be06000
mmap(NULL, 2109728, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff23025c000
mprotect(0x7ff23025e000, 2097152, PROT_NONE) = 0
mmap(0x7ff23045e000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff23045e000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libntdb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libntdb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libntdb.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libntdb.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\34\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647332, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=176, st_size=84480, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/08-17:11:09, st_ctime=2014/01/18-21:56:36}) = 0
mmap(NULL, 2179544, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff230047000
mprotect(0x7ff23005b000, 2093056, PROT_NONE) = 0
mmap(0x7ff23025a000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff23025a000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libcrypt.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libcrypt.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libcrypt.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300\f\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=656041, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=72, st_size=35176, st_atime=2014/01/29-22:55:01, st_mtime=2013/11/29-18:00:15, st_ctime=2013/11/29-22:52:44}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be05000
mmap(NULL, 2318848, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22fe10000
mprotect(0x7ff22fe18000, 2093056, PROT_NONE) = 0
mmap(0x7ff230017000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x7000) = 0x7ff230017000
mmap(0x7ff230019000, 184832, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff230019000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libresolv.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libresolv.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libresolv.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220:\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=655733, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=176, st_size=84856, st_atime=2014/01/30-00:00:01, st_mtime=2013/11/29-18:00:15, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 2189960, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22fbf9000
mprotect(0x7ff22fc0c000, 2097152, PROT_NONE) = 0
mmap(0x7ff22fe0c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff22fe0c000
mmap(0x7ff22fe0e000, 6792, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff22fe0e000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsasl2.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsasl2.so.2", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsasl2.so.2", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2602\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647023, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=224, st_size=109296, st_atime=2014/01/30-21:29:36, st_mtime=2013/10/07-04:19:05, st_ctime=2013/10/27-22:57:51}) = 0
mmap(NULL, 2204624, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22f9de000
mprotect(0x7ff22f9f8000, 2093056, PROT_NONE) = 0
mmap(0x7ff22fbf7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x19000) = 0x7ff22fbf7000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be04000
open("/usr/lib/x86_64-linux-gnu/samba/libauth_sam_reply.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p\r\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347124, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=32, st_size=14512, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2109640, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22f7da000
mprotect(0x7ff22f7dd000, 2093056, PROT_NONE) = 0
mmap(0x7ff22f9dc000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7ff22f9dc000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libndr-krb5pac.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libndr-krb5pac.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libndr-krb5pac.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libndr-krb5pac.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2602\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648942, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=80, st_size=39888, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:21, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 2134944, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22f5d0000
mprotect(0x7ff22f5d9000, 2093056, PROT_NONE) = 0
mmap(0x7ff22f7d8000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8000) = 0x7ff22f7d8000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libwind.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libwind.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libwind.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\20\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648819, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=336, st_size=166136, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:38, st_ctime=2013/12/14-02:46:21}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be03000
mmap(NULL, 2261248, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22f3a7000
mprotect(0x7ff22f3cf000, 2093056, PROT_NONE) = 0
mmap(0x7ff22f5ce000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x27000) = 0x7ff22f5ce000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libheimbase.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libheimbase.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libheimbase.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0003\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648793, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=128, st_size=61344, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:37, st_ctime=2013/12/14-02:46:21}) = 0
mmap(NULL, 2157688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22f198000
mprotect(0x7ff22f1a6000, 2093056, PROT_NONE) = 0
mmap(0x7ff22f3a5000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xd000) = 0x7ff22f3a5000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libhx509.so.5", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libhx509.so.5", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libhx509.so.5", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0` \1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649126, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=608, st_size=304904, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:38, st_ctime=2013/12/14-02:46:22}) = 0
mmap(NULL, 2401192, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22ef4d000
mprotect(0x7ff22ef93000, 2097152, PROT_NONE) = 0
mmap(0x7ff22f193000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x46000) = 0x7ff22f193000
mmap(0x7ff22f197000, 936, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff22f197000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libsqlite3.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libsqlite3.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libsqlite3.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \260\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1646735, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=1504, st_size=763072, st_atime=2014/01/30-07:53:43, st_mtime=2013/12/08-11:59:58, st_ctime=2014/01/11-23:57:25}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be02000
mmap(NULL, 2859736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22ec92000
mprotect(0x7ff22ed48000, 2093056, PROT_NONE) = 0
mmap(0x7ff22ef47000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xb5000) = 0x7ff22ef47000
mmap(0x7ff22ef4c000, 728, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff22ef4c000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libhcrypto.so.4", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libhcrypto.so.4", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libhcrypto.so.4", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000|\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647175, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=432, st_size=213320, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:38, st_ctime=2013/12/14-02:46:21}) = 0
mmap(NULL, 2312264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22ea5d000
mprotect(0x7ff22ea8f000, 2097152, PROT_NONE) = 0
mmap(0x7ff22ec8f000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x32000) = 0x7ff22ec8f000
mmap(0x7ff22ec91000, 2120, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff22ec91000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libroken.so.18", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libroken.so.18", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libroken.so.18", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300T\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647381, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=184, st_size=86096, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:38, st_ctime=2013/12/14-02:45:26}) = 0
mmap(NULL, 2181632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22e848000
mprotect(0x7ff22e85c000, 2093056, PROT_NONE) = 0
mmap(0x7ff22ea5b000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7ff22ea5b000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libheimntlm.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/samba/libheimntlm.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libheimntlm.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\200\36\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1649195, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=27664, st_atime=2014/01/30-21:29:36, st_mtime=2013/12/02-03:11:38, st_ctime=2013/12/14-02:46:22}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24be01000
mmap(NULL, 2122768, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22e641000
mprotect(0x7ff22e647000, 2093056, PROT_NONE) = 0
mmap(0x7ff22e846000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x5000) = 0x7ff22e846000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libuuid.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libuuid.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=330507, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=40, st_size=19032, st_atime=2014/01/29-23:15:01, st_mtime=2013/07/03-03:45:04, st_ctime=2013/07/30-00:57:04}) = 0
mmap(NULL, 20916, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff24bdfb000
mmap(0x7ff24bdff000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7ff24bdff000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libXi.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libXi.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\"\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1647259, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=136, st_size=63880, st_atime=2014/01/30-21:29:36, st_mtime=2013/08/12-18:55:10, st_ctime=2013/08/18-00:58:59}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdfa000
mmap(NULL, 2159272, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22e431000
mprotect(0x7ff22e440000, 2093056, PROT_NONE) = 0
mmap(0x7ff22e63f000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xe000) = 0x7ff22e63f000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/pulseaudio/libFLAC.so.8", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/libFLAC.so.8", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\216\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=1648016, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=408, st_size=203776, st_atime=2014/01/30-21:29:36, st_mtime=2013/09/03-21:45:27, st_ctime=2013/09/08-20:19:31}) = 0
mmap(NULL, 2299032, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22e1ff000
mprotect(0x7ff22e22f000, 2097152, PROT_NONE) = 0
mmap(0x7ff22e42f000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x30000) = 0x7ff22e42f000
close(3)                                = 0
open("/usr/lib/x86_64-linux-gnu/samba/libflag_mapping.so.0", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\10\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=347282, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=16, st_size=6192, st_atime=2014/01/30-21:29:36, st_mtime=2014/01/18-14:13:24, st_ctime=2014/01/18-21:57:26}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf9000
mmap(NULL, 2101320, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22dffd000
mprotect(0x7ff22dffe000, 2093056, PROT_NONE) = 0
mmap(0x7ff22e1fd000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0) = 0x7ff22e1fd000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf8000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf7000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf6000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf5000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf4000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf3000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf2000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf1000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdf0000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdef000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdee000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bded000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdec000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdeb000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdea000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bde8000
arch_prctl(ARCH_SET_FS, 0x7ff24bde8800) = 0
mprotect(0x7ff24159c000, 16384, PROT_READ) = 0
mprotect(0x7ff23ece9000, 4096, PROT_READ) = 0
mprotect(0x7ff23eadc000, 4096, PROT_READ) = 0
mprotect(0x7ff24a476000, 4096, PROT_READ) = 0
mprotect(0x7ff23e694000, 4096, PROT_READ) = 0
mprotect(0x7ff237e8b000, 4096, PROT_READ) = 0
mprotect(0x7ff2411f7000, 4096, PROT_READ) = 0
mprotect(0x7ff22e1fd000, 4096, PROT_READ) = 0
mprotect(0x7ff248636000, 4096, PROT_READ) = 0
mprotect(0x7ff245040000, 4096, PROT_READ) = 0
mprotect(0x7ff22e42f000, 4096, PROT_READ) = 0
mprotect(0x7ff232c7c000, 4096, PROT_READ) = 0
mprotect(0x7ff23d0fe000, 4096, PROT_READ) = 0
mprotect(0x7ff24a67e000, 4096, PROT_READ) = 0
mprotect(0x7ff2441ab000, 4096, PROT_READ) = 0
mprotect(0x7ff2443c1000, 4096, PROT_READ) = 0
mprotect(0x7ff22e63f000, 4096, PROT_READ) = 0
mprotect(0x7ff24bdff000, 4096, PROT_READ) = 0
mprotect(0x7ff230017000, 4096, PROT_READ) = 0
mprotect(0x7ff22fe0c000, 4096, PROT_READ) = 0
mprotect(0x7ff235cb7000, 4096, PROT_READ) = 0
mprotect(0x7ff22ea5b000, 4096, PROT_READ) = 0
mprotect(0x7ff230b1d000, 4096, PROT_READ) = 0
mprotect(0x7ff22f5ce000, 4096, PROT_READ) = 0
mprotect(0x7ff22f3a5000, 4096, PROT_READ) = 0
mprotect(0x7ff22ec8f000, 4096, PROT_READ) = 0
mprotect(0x7ff22f193000, 8192, PROT_READ) = 0
mprotect(0x7ff22ef47000, 12288, PROT_READ) = 0
mprotect(0x7ff2339bc000, 12288, PROT_READ) = 0
mprotect(0x7ff22e846000, 4096, PROT_READ) = 0
mprotect(0x7ff240710000, 98304, PROT_READ) = 0
mprotect(0x7ff240214000, 4096, PROT_READ) = 0
mprotect(0x7ff240944000, 8192, PROT_READ) = 0
mprotect(0x7ff23f9a5000, 53248, PROT_READ) = 0
mprotect(0x7ff22f7d8000, 4096, PROT_READ) = 0
mprotect(0x7ff22f9dc000, 4096, PROT_READ) = 0
mprotect(0x7ff22fbf7000, 4096, PROT_READ) = 0
mprotect(0x7ff23025a000, 4096, PROT_READ) = 0
mprotect(0x7ff234a7c000, 4096, PROT_READ) = 0
mprotect(0x7ff236912000, 4096, PROT_READ) = 0
mprotect(0x7ff23045e000, 4096, PROT_READ) = 0
mprotect(0x7ff236b1e000, 4096, PROT_READ) = 0
mprotect(0x7ff234662000, 4096, PROT_READ) = 0
mprotect(0x7ff23548a000, 4096, PROT_READ) = 0
mprotect(0x7ff234c7f000, 4096, PROT_READ) = 0
mprotect(0x7ff235697000, 4096, PROT_READ) = 0
mprotect(0x7ff2366e2000, 4096, PROT_READ) = 0
mprotect(0x7ff24b47c000, 4096, PROT_READ) = 0
mprotect(0x7ff23785d000, 16384, PROT_READ) = 0
mprotect(0x7ff237375000, 4096, PROT_READ) = 0
mprotect(0x7ff237163000, 4096, PROT_READ) = 0
mprotect(0x7ff232e81000, 4096, PROT_READ) = 0
mprotect(0x7ff23da23000, 4096, PROT_READ) = 0
mprotect(0x7ff2332d4000, 4096, PROT_READ) = 0
mprotect(0x7ff232873000, 4096, PROT_READ) = 0
mprotect(0x7ff2330bd000, 24576, PROT_READ) = 0
mprotect(0x7ff23dcdf000, 24576, PROT_READ) = 0
mprotect(0x7ff2364cd000, 4096, PROT_READ) = 0
mprotect(0x7ff233733000, 4096, PROT_READ) = 0
mprotect(0x7ff236f59000, 4096, PROT_READ) = 0
mprotect(0x7ff233de3000, 4096, PROT_READ) = 0
mprotect(0x7ff230f54000, 4096, PROT_READ) = 0
mprotect(0x7ff230d27000, 4096, PROT_READ) = 0
mprotect(0x7ff23139c000, 4096, PROT_READ) = 0
mprotect(0x7ff23117d000, 8192, PROT_READ) = 0
mprotect(0x7ff237a72000, 4096, PROT_READ) = 0
mprotect(0x7ff230673000, 4096, PROT_READ) = 0
mprotect(0x7ff230876000, 4096, PROT_READ) = 0
mprotect(0x7ff2315a0000, 4096, PROT_READ) = 0
mprotect(0x7ff2317a5000, 4096, PROT_READ) = 0
mprotect(0x7ff234878000, 4096, PROT_READ) = 0
mprotect(0x7ff244873000, 4096, PROT_READ) = 0
mprotect(0x7ff244d27000, 114688, PROT_READ) = 0
mprotect(0x7ff231c0d000, 8192, PROT_READ) = 0
mprotect(0x7ff231e1c000, 4096, PROT_READ) = 0
mprotect(0x7ff232023000, 4096, PROT_READ) = 0
mprotect(0x7ff232668000, 12288, PROT_READ) = 0
mprotect(0x7ff2334f7000, 4096, PROT_READ) = 0
mprotect(0x7ff233bcb000, 4096, PROT_READ) = 0
mprotect(0x7ff233ff0000, 4096, PROT_READ) = 0
mprotect(0x7ff234450000, 4096, PROT_READ) = 0
mprotect(0x7ff23423e000, 8192, PROT_READ) = 0
mprotect(0x7ff234e81000, 4096, PROT_READ) = 0
mprotect(0x7ff235083000, 4096, PROT_READ) = 0
mprotect(0x7ff235286000, 4096, PROT_READ) = 0
mprotect(0x7ff23589a000, 4096, PROT_READ) = 0
mprotect(0x7ff235ab3000, 4096, PROT_READ) = 0
mprotect(0x7ff2360c5000, 4096, PROT_READ) = 0
mprotect(0x7ff235eba000, 4096, PROT_READ) = 0
mprotect(0x7ff2362ca000, 4096, PROT_READ) = 0
mprotect(0x7ff236d41000, 4096, PROT_READ) = 0
mprotect(0x7ff23757d000, 4096, PROT_READ) = 0
mprotect(0x7ff237c7d000, 4096, PROT_READ) = 0
mprotect(0x7ff2382d5000, 4096, PROT_READ) = 0
mprotect(0x7ff239bab000, 4096, PROT_READ) = 0
mprotect(0x7ff238540000, 4096, PROT_READ) = 0
mprotect(0x7ff23874c000, 4096, PROT_READ) = 0
mprotect(0x7ff238958000, 4096, PROT_READ) = 0
mprotect(0x7ff238b6a000, 4096, PROT_READ) = 0
mprotect(0x7ff23918f000, 8192, PROT_READ) = 0
mprotect(0x7ff238f81000, 8192, PROT_READ) = 0
mprotect(0x7ff238d71000, 4096, PROT_READ) = 0
mprotect(0x7ff239394000, 4096, PROT_READ) = 0
mprotect(0x7ff23959d000, 4096, PROT_READ) = 0
mprotect(0x7ff2397a4000, 4096, PROT_READ) = 0
mprotect(0x7ff2399a9000, 4096, PROT_READ) = 0
mprotect(0x7ff23c50b000, 4096, PROT_READ) = 0
mprotect(0x7ff242445000, 4096, PROT_READ) = 0
mprotect(0x7ff23c710000, 4096, PROT_READ) = 0
mprotect(0x7ff24baed000, 16384, PROT_READ) = 0
mprotect(0x7ff23c945000, 4096, PROT_READ) = 0
mprotect(0x7ff23ce60000, 12288, PROT_READ) = 0
mprotect(0x7ff23d7a1000, 8192, PROT_READ) = 0
mprotect(0x7ff23e124000, 8192, PROT_READ) = 0
mprotect(0x7ff23e483000, 32768, PROT_READ) = 0
mprotect(0x7ff23e8cb000, 4096, PROT_READ) = 0
mprotect(0x7ff23ffff000, 4096, PROT_READ) = 0
mprotect(0x7ff23f111000, 8192, PROT_READ) = 0
mprotect(0x7ff240498000, 8192, PROT_READ) = 0
mprotect(0x7ff23eef4000, 4096, PROT_READ) = 0
mprotect(0x7ff23f49a000, 4096, PROT_READ) = 0
mprotect(0x7ff23fbb7000, 4096, PROT_READ) = 0
mprotect(0x7ff23fddf000, 4096, PROT_READ) = 0
mprotect(0x7ff240b49000, 4096, PROT_READ) = 0
mprotect(0x7ff240fc2000, 4096, PROT_READ) = 0
mprotect(0x7ff240d5d000, 4096, PROT_READ) = 0
mprotect(0x7ff2419f0000, 4096, PROT_READ) = 0
mprotect(0x7ff241d15000, 4096, PROT_READ) = 0
mprotect(0x7ff241fa1000, 4096, PROT_READ) = 0
mprotect(0x7ff2472fe000, 4096, PROT_READ) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bde7000
mprotect(0x7ff245be6000, 32768, PROT_READ) = 0
mprotect(0x7ff242667000, 4096, PROT_READ) = 0
mprotect(0x7ff24a96e000, 28672, PROT_READ) = 0
mprotect(0x7ff242c02000, 4096, PROT_READ) = 0
mprotect(0x7ff24bd14000, 4096, PROT_READ) = 0
mprotect(0x7ff242e4c000, 8192, PROT_READ) = 0
mprotect(0x7ff243056000, 4096, PROT_READ) = 0
mprotect(0x7ff24325c000, 4096, PROT_READ) = 0
mprotect(0x7ff24345f000, 4096, PROT_READ) = 0
mprotect(0x7ff243663000, 4096, PROT_READ) = 0
mprotect(0x7ff243c71000, 4096, PROT_READ) = 0
mprotect(0x7ff243868000, 4096, PROT_READ) = 0
mprotect(0x7ff243a6c000, 4096, PROT_READ) = 0
mprotect(0x7ff245255000, 4096, PROT_READ) = 0
mprotect(0x7ff2458fd000, 8192, PROT_READ) = 0
mprotect(0x7ff245e68000, 8192, PROT_READ) = 0
mprotect(0x7ff2460f6000, 12288, PROT_READ) = 0
mprotect(0x7ff24639f000, 4096, PROT_READ) = 0
mprotect(0x7ff246849000, 4096, PROT_READ) = 0
mprotect(0x7ff246a6c000, 4096, PROT_READ) = 0
mprotect(0x7ff246c96000, 4096, PROT_READ) = 0
mprotect(0x7ff24753d000, 4096, PROT_READ) = 0
mprotect(0x7ff24776b000, 4096, PROT_READ) = 0
mprotect(0x7ff247bc1000, 4096, PROT_READ) = 0
mprotect(0x7ff247ded000, 4096, PROT_READ) = 0
mprotect(0x7ff248213000, 4096, PROT_READ) = 0
mprotect(0x7ff248856000, 4096, PROT_READ) = 0
mprotect(0x7ff248a77000, 4096, PROT_READ) = 0
mprotect(0x7ff248c87000, 4096, PROT_READ) = 0
mprotect(0x7ff248eb6000, 8192, PROT_READ) = 0
mprotect(0x7ff24b6a3000, 4096, PROT_READ) = 0
mprotect(0x7ff2497cf000, 24576, PROT_READ) = 0
mprotect(0x7ff24952f000, 8192, PROT_READ) = 0
mprotect(0x7ff2492f4000, 4096, PROT_READ) = 0
mprotect(0x7ff24a024000, 4096, PROT_READ) = 0
mprotect(0x7ff24a25d000, 8192, PROT_READ) = 0
mprotect(0x7ff24ab7e000, 4096, PROT_READ) = 0
mprotect(0x7ff24b8c6000, 4096, PROT_READ) = 0
mprotect(0x7ff24bf37000, 4096, PROT_READ) = 0
munmap(0x7ff24bf15000, 128642)          = 0
set_tid_address(0x7ff24bde8ad0)         = 23881
set_robust_list(0x7ff24bde8ae0, 0x18)   = 0
rt_sigaction(SIGRTMIN, {0x7ff24a2667a0, [], SA_RESTORER|SA_SIGINFO, 0x7ff24a26f210}, NULL, 8) = 0
rt_sigaction(SIGRT_1, {0x7ff24a266820, [], SA_RESTORER|SA_RESTART|SA_SIGINFO, 0x7ff24a26f210}, NULL, 8) = 0
rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024, rlim_max=RLIM_INFINITY}) = 0
brk(0)                                  = 0x7ff24dc04000
brk(0x7ff24dc25000)                     = 0x7ff24dc25000
futex(0x7ff2330c44c0, FUTEX_WAKE_PRIVATE, 2147483647) = 0
futex(0x7ff245c0296c, FUTEX_WAKE_PRIVATE, 2147483647) = 0
futex(0x7ff245c02978, FUTEX_WAKE_PRIVATE, 2147483647) = 0
futex(0x7ff24a67f0c8, FUTEX_WAKE_PRIVATE, 2147483647) = 0
open("/proc/self/maps", O_RDONLY)       = 3
lseek(3, 0, SEEK_SET)                   = 0
read(3, "7ff22dffd000-7ff22dffe000 r-xp 0"..., 4096) = 4063
read(3, "7ff22f1a6000-7ff22f3a5000 ---p 0"..., 4096) = 4000
read(3, "7ff23045e000-7ff23045f000 r--p 0"..., 4096) = 4042
read(3, "7ff2315a1000-7ff2315a2000 rw-p 0"..., 4096) = 4021
read(3, "7ff232874000-7ff232875000 rw-p 0"..., 4096) = 4093
read(3, "7ff233bcc000-7ff233bcd000 rw-p 0"..., 4096) = 4043
read(3, "7ff234c81000-7ff234c82000 r-xp 0"..., 4096) = 4018
read(3, "7ff235cbb000-7ff235eba000 ---p 0"..., 4096) = 4068
read(3, "7ff236f59000-7ff236f5a000 r--p 0"..., 4096) = 4061
read(3, "7ff238091000-7ff2380d6000 r-xp 0"..., 4096) = 4058
read(3, "7ff239394000-7ff239395000 r--p 0"..., 4096) = 4064
read(3, "7ff23c746000-7ff23c945000 ---p 0"..., 4096) = 4055
read(3, "7ff23defc000-7ff23defd000 rw-p 0"..., 4096) = 3980
read(3, "7ff23f114000-7ff23f29a000 r-xp 0"..., 4096) = 4061
read(3, "7ff240745000-7ff240944000 ---p 0"..., 4096) = 4047
read(3, "7ff241d16000-7ff241d17000 rw-p 0"..., 4096) = 3979
read(3, "7ff24305d000-7ff24325c000 ---p 0"..., 4096) = 4086
read(3, "7ff244444000-7ff244644000 ---p 0"..., 4096) = 3983
read(3, "7ff245e6a000-7ff245e6b000 rw-p 0"..., 4096) = 4095
read(3, "7ff2472ff000-7ff247300000 rw-p 0"..., 4096) = 3983
read(3, "7ff248638000-7ff248656000 r-xp 0"..., 4096) = 4033
read(3, "7ff2499fd000-7ff249bfc000 ---p 0"..., 4096) = 3980
read(3, "7ff24afdb000-7ff24afdc000 rw-p 0"..., 4096) = 4059
read(3, "7ff24dc04000-7ff24dc25000 rw-p 0"..., 4096) = 325
read(3, "", 4096)                       = 0
close(3)                                = 0
brk(0x7ff24dc50000)                     = 0x7ff24dc50000
brk(0x7ff24dc46000)                     = 0x7ff24dc46000
mmap(NULL, 176128, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bdbc000
brk(0x7ff24dc3c000)                     = 0x7ff24dc3c000
mremap(0x7ff24bdbc000, 176128, 180224, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 180224, 184320, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 184320, 188416, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 188416, 192512, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 192512, 196608, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 196608, 200704, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 200704, 204800, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 204800, 208896, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 208896, 212992, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 212992, 217088, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 217088, 221184, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 221184, 225280, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 225280, 229376, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 229376, 233472, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 233472, 237568, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 237568, 241664, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 241664, 245760, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 245760, 249856, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 249856, 253952, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 253952, 258048, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 258048, 262144, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 262144, 266240, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 266240, 270336, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 270336, 274432, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 274432, 278528, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 278528, 282624, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 282624, 286720, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 286720, 290816, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 290816, 294912, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 294912, 299008, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 299008, 303104, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 303104, 307200, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 307200, 311296, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 311296, 315392, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 315392, 319488, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 319488, 323584, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 323584, 327680, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 327680, 331776, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 331776, 335872, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 335872, 339968, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 339968, 344064, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 344064, 348160, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 348160, 356352, MREMAP_MAYMOVE) = 0x7ff24bd90000
mremap(0x7ff24bd90000, 356352, 360448, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 360448, 364544, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 364544, 368640, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 368640, 372736, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 372736, 376832, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 376832, 380928, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 380928, 385024, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 385024, 389120, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 389120, 393216, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 393216, 397312, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 397312, 401408, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 401408, 405504, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 405504, 409600, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 409600, 413696, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 413696, 417792, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 417792, 421888, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 421888, 425984, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 425984, 430080, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 430080, 434176, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 434176, 438272, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 438272, 442368, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 442368, 446464, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 446464, 450560, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 450560, 454656, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 454656, 458752, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 458752, 462848, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 462848, 466944, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 466944, 471040, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 471040, 475136, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 475136, 479232, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 479232, 483328, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 483328, 487424, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 487424, 491520, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 491520, 495616, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 495616, 499712, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 499712, 503808, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 503808, 507904, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 507904, 512000, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 512000, 516096, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 516096, 520192, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 520192, 524288, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 524288, 528384, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 528384, 532480, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 532480, 536576, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 536576, 540672, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 540672, 544768, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 544768, 548864, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 548864, 552960, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 552960, 557056, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 557056, 561152, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 561152, 565248, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 565248, 569344, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 569344, 573440, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 573440, 577536, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 577536, 581632, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 581632, 585728, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 585728, 589824, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 589824, 593920, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 593920, 598016, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 598016, 602112, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 602112, 606208, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 606208, 610304, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 610304, 614400, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 614400, 618496, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 618496, 622592, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 622592, 626688, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 626688, 630784, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 630784, 634880, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 634880, 638976, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 638976, 643072, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 643072, 647168, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 647168, 651264, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 651264, 655360, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 655360, 659456, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 659456, 663552, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 663552, 667648, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 667648, 671744, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 671744, 675840, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 675840, 679936, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 679936, 684032, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 684032, 688128, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 688128, 692224, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 692224, 696320, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 696320, 700416, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 700416, 704512, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 704512, 712704, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 712704, 716800, MREMAP_MAYMOVE) = 0x7ff24bd38000
mremap(0x7ff24bd38000, 716800, 720896, MREMAP_MAYMOVE) = 0x7ff22df4d000
mremap(0x7ff22df4d000, 720896, 724992, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 724992, 729088, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 729088, 733184, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 733184, 737280, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 737280, 741376, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 741376, 745472, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 745472, 749568, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 749568, 753664, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 753664, 757760, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 757760, 761856, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 761856, 765952, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 765952, 770048, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 770048, 774144, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 774144, 778240, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 778240, 782336, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 782336, 786432, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 786432, 790528, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 790528, 794624, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 794624, 798720, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 798720, 802816, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 802816, 806912, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 806912, 811008, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 811008, 815104, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 815104, 819200, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 819200, 823296, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 823296, 827392, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 827392, 831488, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 831488, 835584, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 835584, 839680, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 839680, 843776, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 843776, 847872, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 847872, 851968, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 851968, 856064, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 856064, 860160, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 860160, 864256, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 864256, 868352, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 868352, 872448, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 872448, 876544, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 876544, 880640, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 880640, 884736, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 884736, 888832, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 888832, 892928, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 892928, 897024, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 897024, 901120, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 901120, 905216, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 905216, 909312, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 909312, 913408, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 913408, 917504, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 917504, 921600, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 921600, 925696, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 925696, 929792, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 929792, 933888, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 933888, 937984, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 937984, 942080, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 942080, 946176, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 946176, 950272, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 950272, 954368, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 954368, 958464, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 958464, 962560, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 962560, 966656, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 966656, 970752, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 970752, 974848, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 974848, 978944, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 978944, 983040, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 983040, 987136, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 987136, 991232, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 991232, 995328, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 995328, 999424, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 999424, 1003520, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1003520, 1007616, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1007616, 1011712, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1011712, 1015808, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1015808, 1019904, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1019904, 1024000, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1024000, 1028096, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1028096, 1032192, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1032192, 1036288, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1036288, 1040384, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1040384, 1044480, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1044480, 1048576, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1048576, 1052672, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1052672, 1056768, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1056768, 1064960, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1064960, 1069056, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1069056, 1073152, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1073152, 1077248, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1077248, 1081344, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1081344, 1085440, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1085440, 1089536, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1089536, 1093632, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1093632, 1097728, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1097728, 1101824, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1101824, 1105920, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1105920, 1110016, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1110016, 1114112, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1114112, 1118208, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1118208, 1122304, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1122304, 1126400, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1126400, 1130496, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1130496, 1134592, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1134592, 1138688, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1138688, 1142784, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1142784, 1146880, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1146880, 1150976, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1150976, 1155072, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1155072, 1159168, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1159168, 1163264, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1163264, 1167360, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1167360, 1171456, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1171456, 1175552, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1175552, 1179648, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1179648, 1183744, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1183744, 1187840, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1187840, 1191936, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1191936, 1196032, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1196032, 1200128, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1200128, 1204224, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1204224, 1208320, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1208320, 1212416, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1212416, 1216512, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1216512, 1220608, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1220608, 1224704, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1224704, 1228800, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1228800, 1232896, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1232896, 1236992, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1236992, 1241088, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1241088, 1245184, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1245184, 1249280, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1249280, 1253376, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1253376, 1257472, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1257472, 1261568, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1261568, 1265664, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1265664, 1269760, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1269760, 1273856, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1273856, 1277952, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1277952, 1282048, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1282048, 1286144, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1286144, 1290240, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1290240, 1294336, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1294336, 1298432, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1298432, 1302528, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1302528, 1306624, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1306624, 1310720, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1310720, 1314816, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1314816, 1318912, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1318912, 1323008, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1323008, 1327104, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1327104, 1331200, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1331200, 1335296, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1335296, 1339392, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1339392, 1343488, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1343488, 1347584, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1347584, 1351680, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1351680, 1355776, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1355776, 1359872, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1359872, 1363968, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1363968, 1368064, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1368064, 1372160, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1372160, 1376256, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1376256, 1380352, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1380352, 1384448, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1384448, 1388544, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1388544, 1392640, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1392640, 1396736, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1396736, 1400832, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1400832, 1404928, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1404928, 1409024, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1409024, 1417216, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1417216, 1421312, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1421312, 1425408, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1425408, 1429504, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1429504, 1433600, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1433600, 1437696, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1437696, 1441792, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1441792, 1445888, MREMAP_MAYMOVE) = 0x7ff22de9c000
mremap(0x7ff22de9c000, 1445888, 1449984, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1449984, 1454080, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1454080, 1458176, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1458176, 1462272, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1462272, 1466368, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1466368, 1470464, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1470464, 1474560, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1474560, 1478656, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1478656, 1482752, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1482752, 1486848, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1486848, 1490944, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1490944, 1495040, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1495040, 1499136, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1499136, 1503232, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1503232, 1507328, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1507328, 1511424, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1511424, 1515520, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1515520, 1519616, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1519616, 1523712, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1523712, 1527808, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1527808, 1531904, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1531904, 1536000, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1536000, 1540096, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1540096, 1544192, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1544192, 1548288, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1548288, 1552384, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1552384, 1556480, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1556480, 1560576, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1560576, 1564672, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1564672, 1568768, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1568768, 1572864, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1572864, 1576960, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1576960, 1581056, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1581056, 1585152, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1585152, 1589248, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1589248, 1593344, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1593344, 1597440, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1597440, 1601536, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1601536, 1605632, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1605632, 1609728, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1609728, 1613824, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1613824, 1617920, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1617920, 1622016, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1622016, 1626112, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1626112, 1630208, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1630208, 1634304, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1634304, 1638400, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1638400, 1642496, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1642496, 1646592, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1646592, 1650688, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1650688, 1654784, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1654784, 1658880, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1658880, 1662976, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1662976, 1667072, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1667072, 1671168, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1671168, 1675264, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1675264, 1679360, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1679360, 1683456, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1683456, 1687552, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1687552, 1691648, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1691648, 1695744, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1695744, 1699840, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1699840, 1703936, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1703936, 1708032, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1708032, 1712128, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1712128, 1716224, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1716224, 1720320, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1720320, 1724416, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1724416, 1728512, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1728512, 1732608, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1732608, 1736704, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1736704, 1740800, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1740800, 1744896, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1744896, 1748992, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1748992, 1753088, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1753088, 1757184, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1757184, 1761280, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1761280, 1765376, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1765376, 1773568, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1773568, 1777664, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1777664, 1781760, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1781760, 1785856, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1785856, 1789952, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1789952, 1794048, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1794048, 1798144, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1798144, 1802240, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1802240, 1806336, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1806336, 1810432, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1810432, 1814528, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1814528, 1818624, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1818624, 1822720, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1822720, 1826816, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1826816, 1830912, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1830912, 1835008, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1835008, 1839104, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1839104, 1843200, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1843200, 1847296, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1847296, 1851392, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1851392, 1855488, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1855488, 1859584, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1859584, 1863680, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1863680, 1867776, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1867776, 1871872, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1871872, 1875968, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1875968, 1880064, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1880064, 1884160, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1884160, 1888256, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1888256, 1892352, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1892352, 1896448, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1896448, 1900544, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1900544, 1904640, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1904640, 1908736, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1908736, 1912832, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1912832, 1916928, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1916928, 1921024, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1921024, 1925120, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1925120, 1929216, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1929216, 1933312, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1933312, 1937408, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1937408, 1941504, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1941504, 1945600, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1945600, 1949696, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1949696, 1953792, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1953792, 1957888, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1957888, 1961984, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1961984, 1966080, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1966080, 1970176, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1970176, 1974272, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1974272, 1978368, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1978368, 1982464, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1982464, 1986560, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1986560, 1990656, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1990656, 1994752, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1994752, 1998848, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 1998848, 2002944, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2002944, 2007040, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2007040, 2011136, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2011136, 2015232, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2015232, 2019328, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2019328, 2023424, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2023424, 2027520, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2027520, 2031616, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2031616, 2035712, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2035712, 2039808, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2039808, 2043904, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2043904, 2048000, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2048000, 2052096, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2052096, 2056192, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2056192, 2060288, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2060288, 2064384, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2064384, 2068480, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2068480, 2072576, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2072576, 2076672, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2076672, 2080768, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2080768, 2084864, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2084864, 2088960, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2088960, 2093056, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2093056, 2097152, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2097152, 2101248, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2101248, 2105344, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2105344, 2109440, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2109440, 2113536, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2113536, 2117632, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2117632, 2125824, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2125824, 2129920, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2129920, 2134016, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2134016, 2138112, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2138112, 2142208, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2142208, 2146304, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2146304, 2150400, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2150400, 2154496, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2154496, 2158592, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2158592, 2162688, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2162688, 2166784, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2166784, 2170880, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2170880, 2174976, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2174976, 2179072, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2179072, 2183168, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2183168, 2187264, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2187264, 2191360, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2191360, 2195456, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2195456, 2199552, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2199552, 2203648, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2203648, 2207744, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2207744, 2211840, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2211840, 2215936, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2215936, 2220032, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2220032, 2224128, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2224128, 2228224, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2228224, 2232320, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2232320, 2236416, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2236416, 2240512, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2240512, 2244608, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2244608, 2248704, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2248704, 2252800, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2252800, 2256896, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2256896, 2260992, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2260992, 2265088, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2265088, 2269184, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2269184, 2273280, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2273280, 2277376, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2277376, 2281472, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2281472, 2285568, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2285568, 2289664, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2289664, 2293760, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2293760, 2297856, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2297856, 2301952, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2301952, 2306048, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2306048, 2310144, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2310144, 2314240, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2314240, 2318336, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2318336, 2322432, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2322432, 2326528, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2326528, 2330624, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2330624, 2334720, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2334720, 2338816, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2338816, 2342912, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2342912, 2347008, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2347008, 2351104, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2351104, 2355200, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2355200, 2359296, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2359296, 2363392, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2363392, 2367488, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2367488, 2371584, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2371584, 2375680, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2375680, 2379776, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2379776, 2383872, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2383872, 2387968, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2387968, 2392064, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2392064, 2396160, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2396160, 2400256, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2400256, 2404352, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2404352, 2408448, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2408448, 2412544, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2412544, 2416640, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2416640, 2420736, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2420736, 2424832, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2424832, 2428928, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2428928, 2433024, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2433024, 2437120, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2437120, 2441216, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2441216, 2445312, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2445312, 2449408, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2449408, 2453504, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2453504, 2457600, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2457600, 2461696, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2461696, 2465792, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2465792, 2469888, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2469888, 2478080, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2478080, 2482176, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2482176, 2486272, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2486272, 2490368, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2490368, 2494464, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2494464, 2498560, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2498560, 2502656, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2502656, 2506752, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2506752, 2510848, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2510848, 2514944, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2514944, 2519040, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2519040, 2523136, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2523136, 2527232, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2527232, 2531328, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2531328, 2535424, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2535424, 2539520, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2539520, 2543616, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2543616, 2547712, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2547712, 2551808, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2551808, 2555904, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2555904, 2560000, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2560000, 2564096, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2564096, 2568192, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2568192, 2572288, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2572288, 2576384, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2576384, 2580480, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2580480, 2584576, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2584576, 2588672, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2588672, 2592768, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2592768, 2596864, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2596864, 2600960, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2600960, 2605056, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2605056, 2609152, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2609152, 2613248, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2613248, 2617344, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2617344, 2621440, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2621440, 2625536, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2625536, 2629632, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2629632, 2633728, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2633728, 2637824, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2637824, 2641920, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2641920, 2646016, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2646016, 2650112, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2650112, 2654208, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2654208, 2658304, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2658304, 2662400, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2662400, 2666496, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2666496, 2670592, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2670592, 2674688, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2674688, 2678784, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2678784, 2682880, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2682880, 2686976, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2686976, 2691072, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2691072, 2695168, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2695168, 2699264, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2699264, 2703360, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2703360, 2707456, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2707456, 2711552, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2711552, 2715648, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2715648, 2719744, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2719744, 2723840, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2723840, 2727936, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2727936, 2732032, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2732032, 2736128, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2736128, 2740224, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2740224, 2744320, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2744320, 2748416, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2748416, 2752512, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2752512, 2756608, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2756608, 2760704, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2760704, 2764800, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2764800, 2768896, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2768896, 2772992, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2772992, 2777088, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2777088, 2781184, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2781184, 2785280, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2785280, 2789376, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2789376, 2793472, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2793472, 2797568, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2797568, 2801664, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2801664, 2805760, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2805760, 2809856, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2809856, 2813952, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2813952, 2818048, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2818048, 2822144, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2822144, 2826240, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2826240, 2834432, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2834432, 2838528, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2838528, 2842624, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2842624, 2846720, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2846720, 2850816, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2850816, 2854912, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2854912, 2859008, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2859008, 2863104, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2863104, 2867200, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2867200, 2871296, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2871296, 2875392, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2875392, 2879488, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2879488, 2883584, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2883584, 2887680, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2887680, 2891776, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2891776, 2895872, MREMAP_MAYMOVE) = 0x7ff22dd3a000
mremap(0x7ff22dd3a000, 2895872, 2899968, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2899968, 2904064, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2904064, 2908160, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2908160, 2912256, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2912256, 2916352, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2916352, 2920448, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2920448, 2924544, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2924544, 2928640, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2928640, 2932736, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2932736, 2936832, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2936832, 2940928, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2940928, 2945024, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2945024, 2949120, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2949120, 2953216, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2953216, 2957312, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2957312, 2961408, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2961408, 2965504, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2965504, 2969600, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2969600, 2973696, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2973696, 2977792, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2977792, 2981888, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2981888, 2985984, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2985984, 2990080, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2990080, 2994176, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2994176, 2998272, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 2998272, 3002368, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3002368, 3006464, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3006464, 3010560, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3010560, 3014656, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3014656, 3018752, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3018752, 3022848, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3022848, 3026944, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3026944, 3031040, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3031040, 3035136, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3035136, 3039232, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3039232, 3043328, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3043328, 3047424, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3047424, 3051520, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3051520, 3055616, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3055616, 3059712, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3059712, 3063808, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3063808, 3067904, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3067904, 3072000, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3072000, 3076096, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3076096, 3080192, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3080192, 3084288, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3084288, 3088384, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3088384, 3092480, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3092480, 3096576, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3096576, 3100672, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3100672, 3104768, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3104768, 3108864, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3108864, 3112960, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3112960, 3117056, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3117056, 3121152, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3121152, 3125248, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3125248, 3129344, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3129344, 3133440, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3133440, 3137536, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3137536, 3141632, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3141632, 3145728, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3145728, 3149824, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3149824, 3153920, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3153920, 3158016, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3158016, 3162112, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3162112, 3166208, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3166208, 3170304, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3170304, 3174400, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3174400, 3178496, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3178496, 3186688, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3186688, 3190784, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3190784, 3194880, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3194880, 3198976, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3198976, 3203072, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3203072, 3207168, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3207168, 3211264, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3211264, 3215360, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3215360, 3219456, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3219456, 3223552, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3223552, 3227648, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3227648, 3231744, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3231744, 3235840, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3235840, 3239936, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3239936, 3244032, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3244032, 3248128, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3248128, 3252224, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3252224, 3256320, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3256320, 3260416, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3260416, 3264512, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3264512, 3268608, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3268608, 3272704, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3272704, 3276800, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3276800, 3280896, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3280896, 3284992, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3284992, 3289088, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3289088, 3293184, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3293184, 3297280, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3297280, 3301376, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3301376, 3305472, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3305472, 3309568, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3309568, 3313664, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3313664, 3317760, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3317760, 3321856, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3321856, 3325952, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3325952, 3330048, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3330048, 3334144, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3334144, 3338240, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3338240, 3342336, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3342336, 3346432, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3346432, 3350528, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3350528, 3354624, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3354624, 3358720, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3358720, 3362816, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3362816, 3366912, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3366912, 3371008, MREMAP_MAYMOVE) = 0x7ff22da76000
mremap(0x7ff22da76000, 3371008, 3375104, MREMAP_MAYMOVE) = 0x7ff22da76000
brk(0x7ff24dc25000)                     = 0x7ff24dc25000
munmap(0x7ff22da76000, 3375104)         = 0
open("/home/sesse/.nv/nvidia-application-profile-globals-rc", O_RDONLY) = -1 ENOENT (No such file or directory)
readlink("/proc/23881/exe", "/usr/bin/mplayer1", 4096) = 17
clock_gettime(CLOCK_MONOTONIC, {244180, 254645536}) = 0
clock_gettime(CLOCK_MONOTONIC, {244180, 254777393}) = 0
brk(0x7ff24dc66000)                     = 0x7ff24dc66000
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_dev=makedev(254, 0), st_ino=2696180, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=264, st_size=128642, st_atime=2014/01/30-01:50:01, st_mtime=2014/01/23-01:47:27, st_ctime=2014/01/23-01:47:27}) = 0
mmap(NULL, 128642, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7ff24bf15000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 b\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328864, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=280, st_size=138608, st_atime=2014/01/29-21:55:02, st_mtime=2014/01/11-18:46:44, st_ctime=2014/01/18-21:51:01}) = 0
mmap(NULL, 2242640, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22ddd9000
mprotect(0x7ff22ddf9000, 2097152, PROT_NONE) = 0
mmap(0x7ff22dff9000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x20000) = 0x7ff22dff9000
mmap(0x7ff22dffb000, 6224, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff22dffb000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libpcre.so.3", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\32\0\0\0\0\0\0"..., 832) = 832
fstat(3, {st_dev=makedev(254, 0), st_ino=328772, st_mode=S_IFREG|0644, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=512, st_size=254144, st_atime=2014/01/29-23:10:02, st_mtime=2013/01/03-22:30:46, st_ctime=2013/06/10-01:07:37}) = 0
mmap(NULL, 2349248, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff22db9b000
mprotect(0x7ff22dbd9000, 2093056, PROT_NONE) = 0
mmap(0x7ff22ddd8000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3d000) = 0x7ff22ddd8000
close(3)                                = 0
mprotect(0x7ff22dff9000, 4096, PROT_READ) = 0
statfs("/sys/fs/selinux", 0x7fffb75340c0) = -1 ENOENT (No such file or directory)
statfs("/selinux", 0x7fffb75340c0)      = -1 ENOENT (No such file or directory)
open("/proc/filesystems", O_RDONLY)     = 3
fstat(3, {st_dev=makedev(0, 3), st_ino=4026532016, st_mode=S_IFREG|0444, st_nlink=1, st_uid=0, st_gid=0, st_blksize=1024, st_blocks=0, st_size=0, st_atime=2014/01/30-21:29:58, st_mtime=2014/01/30-21:29:58, st_ctime=2014/01/30-21:29:58}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bde6000
read(3, "nodev\tsysfs\nnodev\trootfs\nnodev\tb"..., 1024) = 320
read(3, "", 1024)                       = 0
close(3)                                = 0
munmap(0x7ff24bde6000, 4096)            = 0
munmap(0x7ff24bf15000, 128642)          = 0
munmap(0x7ff22ddd9000, 2242640)         = 0
munmap(0x7ff22db9b000, 2349248)         = 0
getpid()                                = 23881
getpid()                                = 23881
getpid()                                = 23881
futex(0x7ff242981758, FUTEX_WAKE_PRIVATE, 2147483647) = 0
clock_gettime(CLOCK_MONOTONIC, {244180, 265714877}) = 0
open("/proc/self/status", O_RDONLY)     = 3
lseek(3, 0, SEEK_SET)                   = 0
read(3, "Name:\tmplayer\nState:\tR (running)"..., 256) = 256
close(3)                                = 0
open("/proc/self/status", O_RDONLY)     = 3
lseek(3, 0, SEEK_SET)                   = 0
read(3, "Name:\tmplayer\nState:\tR (running)"..., 256) = 256
close(3)                                = 0
readlink("/proc/23881/exe", "/usr/bin/mplayer1", 4096) = 17
open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_dev=makedev(254, 0), st_ino=1376494, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=2992, st_size=1608128, st_atime=2014/01/30-20:15:01, st_mtime=2013/11/30-20:04:08, st_ctime=2013/11/30-20:04:39}) = 0
mmap(NULL, 1608128, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7ff22de74000
close(3)                                = 0
brk(0x7ff24dc87000)                     = 0x7ff24dc87000
open("/etc/mplayer/mplayer.conf", O_RDONLY) = 3
fstat(3, {st_dev=makedev(254, 0), st_ino=2392071, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=16, st_size=4300, st_atime=2014/01/30-21:29:36, st_mtime=2013/07/14-18:38:17, st_ctime=2013/08/18-01:03:04}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf34000
read(3, "#\n# MPlayer configuration file\n#"..., 4096) = 4096
read(3, "ilters do not work with vdpau.\n#"..., 4096) = 204
open("/etc/mplayer/mplayer.conf.local", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 4
fstat(4, {st_dev=makedev(254, 0), st_ino=1720620, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=56, st_size=26258, st_atime=2014/01/29-23:30:02, st_mtime=2013/11/29-17:54:14, st_ctime=2013/11/29-22:52:44}) = 0
mmap(NULL, 26258, PROT_READ, MAP_SHARED, 4, 0) = 0x7ff24bf2d000
close(4)                                = 0
futex(0x7ff2415a1918, FUTEX_WAKE_PRIVATE, 2147483647) = 0
write(2, "Failed to read /etc/mplayer/mpla"..., 74Failed to read /etc/mplayer/mplayer.conf.local: No such file or directory
) = 74
write(2, "Warning unknown option include a"..., 43Warning unknown option include at line 177
) = 43
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x7ff24bf34000, 4096)            = 0
mkdir("/home/sesse/.mplayer/", 0777)    = -1 EEXIST (File exists)
open("/home/sesse/.mplayer/config", O_WRONLY|O_CREAT|O_EXCL, 0666) = -1 EEXIST (File exists)
open("/home/sesse/.mplayer/config", O_RDONLY) = 3
fstat(3, {st_dev=makedev(254, 0), st_ino=2156349, st_mode=S_IFREG|0644, st_nlink=1, st_uid=1000, st_gid=1000, st_blksize=4096, st_blocks=8, st_size=151, st_atime=2014/01/30-21:29:36, st_mtime=2012/09/29-19:29:14, st_ctime=2012/09/29-19:29:14}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf34000
read(3, "ac=hwdts,hwac3,\nvc=ffh264vdpau,f"..., 4096) = 151
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x7ff24bf34000, 4096)            = 0
fstat(1, {st_dev=makedev(254, 0), st_ino=984153, st_mode=S_IFREG|0640, st_nlink=1, st_uid=1000, st_gid=1000, st_blksize=4096, st_blocks=504, st_size=253041, st_atime=2014/01/25-14:01:30, st_mtime=2014/01/30-21:29:58, st_ctime=2014/01/30-21:29:58}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf34000
write(1, "MPlayer SVN-r36533 (C) 2000-2012"..., 46MPlayer SVN-r36533 (C) 2000-2012 MPlayer Team
) = 46
open("/home/sesse/.mplayer/codecs.conf", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/etc/mplayer/codecs.conf", O_RDONLY) = -1 ENOENT (No such file or directory)
brk(0x7ff24dcaa000)                     = 0x7ff24dcaa000
ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fffb75335d0) = -1 ENOTTY (Inappropriate ioctl for device)
stat("/home/sesse/.terminfo", 0x7ff24dc94580) = -1 ENOENT (No such file or directory)
stat("/etc/terminfo", {st_dev=makedev(254, 0), st_ino=2695269, st_mode=S_IFDIR|0755, st_nlink=2, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=4096, st_atime=2014/01/18-19:56:07, st_mtime=2014/01/22-21:56:32, st_ctime=2014/01/22-21:56:32}) = 0
stat("/lib/terminfo", {st_dev=makedev(254, 0), st_ino=319620, st_mode=S_IFDIR|0755, st_nlink=15, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=4096, st_atime=2011/01/04-04:33:04, st_mtime=2012/08/26-22:00:27, st_ctime=2012/08/26-22:00:27}) = 0
stat("/usr/share/terminfo", {st_dev=makedev(254, 0), st_ino=1368276, st_mode=S_IFDIR|0755, st_nlink=44, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=4096, st_atime=2011/01/04-04:33:10, st_mtime=2012/08/26-22:09:15, st_ctime=2012/08/26-22:09:15}) = 0
access("/etc/terminfo/r/rxvt-unicode", R_OK) = -1 ENOENT (No such file or directory)
access("/lib/terminfo/r/rxvt-unicode", R_OK) = 0
open("/lib/terminfo/r/rxvt-unicode", O_RDONLY) = 3
fstat(3, {st_dev=makedev(254, 0), st_ino=319650, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=8, st_size=2200, st_atime=2014/01/30-21:29:31, st_mtime=2014/01/20-18:46:34, st_ctime=2014/01/22-21:56:32}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff24bf2c000
read(3, "\32\0015\0\35\0\37\0p\1\34\5rxvt-unicode|rxvt-un"..., 4096) = 2200
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0x7ff24bf2c000, 4096)            = 0
ioctl(2, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fffb75335d0) = -1 ENOTTY (Inappropriate ioctl for device)
ioctl(2, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fffb7533570) = -1 ENOTTY (Inappropriate ioctl for device)
open("/home/sesse/.mplayer/input.conf", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/etc/mplayer/input.conf", O_RDONLY) = 3
read(3, "##\n## MPlayer input control file"..., 255) = 255
read(3, "le ", 3)                       = 3
read(3, "options.\n## The file should be", 30) = 30
read(3, " pl", 3)                       = 3
read(3, "aced in the $HOME/.mplayer direc"..., 78) = 78
read(3, "ey ignore.\n## e.g. ENT", 22)  = 22
read(3, "ER ignore\n##\n\nRIGHT seek +10\nLEF"..., 68) = 68
read(3, "\nPGUP seek 600\nPGDWN seek -600\nm"..., 63) = 63
read(3, " switch audio streams\n+ audio_de"..., 62) = 62
read(3, "- a", 3)                       = 3
read(3, "udio_delay -0.100\n[ speed_mult 0"..., 48) = 48
read(3, "ayback speed\n] speed_", 21)   = 21
read(3, "mul", 3)                       = 3
read(3, "t 1.1\n{", 7)                  = 7
read(3, " speed_mu", 9)                 = 9
read(3, "lt 0.", 5)                     = 5
read(3, "5\n} speed", 9)                = 9
read(3, "_mult", 5)                     = 5
read(3, " 2.0\nBS s", 9)                = 9
read(3, "pee", 3)                       = 3
read(3, "d_set 1.0", 9)                 = 9
read(3, "\t# re", 5)                    = 5
read(3, "set speed", 9)                 = 9
read(3, " to no", 6)                    = 6
read(3, "rmal\nq qui", 10)              = 10
read(3, "t\n", 2)                       = 2
read(3, "ESC q", 5)                     = 5
read(3, "uit\nENTER pt_step 1 1       # sk"..., 47) = 47
read(3, "\np", 2)                       = 2
read(3, " pause\n. frame_ste", 18)      = 18
read(3, "p ", 2)                        = 2
read(3, "           # advan", 18)       = 18
read(3, "ce", 2)                        = 2
read(3, " one frame and paus", 19)      = 19
read(3, "e\n", 2)                       = 2
read(3, "SPACE pause\nHOME pt_up_step 1\nEN"..., 41) = 41
read(3, "te", 2)                        = 2
read(3, "p -1\n> pt_step ", 15)         = 15
read(3, "1 ", 2)                        = 2
read(3, "            # s", 15)          = 15
read(3, "ki", 2)                        = 2
read(3, "p to next file\n", 15)         = 15
read(3, "< p", 3)                       = 3
read(3, "t_step -1            #         p"..., 38) = 38
read(3, "s\n", 2)                       = 2
read(3, "INS a", 5)                     = 5
read(3, "lt_s", 4)                      = 4
read(3, "rc_st", 5)                     = 5
read(3, "ep 1\nD", 6)                   = 6
read(3, "EL alt_src_step -1\no osd\nI osd_s"..., 38) = 38
read(3, "op", 2)                        = 2
read(3, "erty_t", 6)                    = 6
read(3, "ex", 2)                        = 2
read(3, "t \"${filename}\"     # display fi"..., 52) = 52
read(3, "show_p", 6)                    = 6
read(3, "rogres", 6)                    = 6
read(3, "sion\n", 5)                    = 5
read(3, "z sub_delay -", 13)            = 13
read(3, "0.1 ", 4)                      = 4
read(3, "       # subtr", 14)           = 14
read(3, "ac", 2)                        = 2
read(3, "t 100 ms delay from subs\nx sub_d"..., 42) = 42
read(3, "  ", 2)                        = 2
read(3, "     # add\n9 volume -1\n/ volume "..., 41) = 41
read(3, "me 1", 4)                      = 4
read(3, "\n* volume 1\n1 c", 15)        = 15
read(3, "ontr", 4)                      = 4
read(3, "ast -1\n2 contras", 16)        = 16
read(3, "t ", 2)                        = 2
read(3, "1\n3 ", 4)                     = 4
read(3, "br", 2)                        = 2
read(3, "ightness -1\n4 brightness 1\n5 hue"..., 67) = 67
read(3, "at", 2)                        = 2
read(3, "ion 1\n( balance -0.1 ", 21)   = 21
read(3, "  ", 2)                        = 2
read(3, "       # adjust audio balance in"..., 56) = 56
read(3, " +", 2)                        = 2
read(3, "0.1          #              ", 28) = 28
read(3, "  ", 2)                        = 2
read(3, "          ", 10)               = 10
read(3, "  ", 2)                        = 2
read(3, "      righ", 10)               = 10
read(3, "t\n", 2)                       = 2
read(3, "d frame_d", 9)                 = 9
read(3, "ro", 2)                        = 2
read(3, "p\nD step_", 9)                = 9
read(3, "pr", 2)                        = 2
read(3, "operty deint", 12)             = 12
read(3, "er", 2)                        = 2
read(3, "lace  # tog", 11)              = 11
read(3, "gl", 2)                        = 2
read(3, "e deinterlacer", 14)           = 14
read(3, ", ", 2)                        = 2
read(3, "requires -vf ", 13)            = 13
read(3, "ya", 2)                        = 2
read(3, "dif or ", 7)                   = 7
read(3, "ke", 2)                        = 2
read(3, "rndein", 6)                    = 6
read(3, "t\n", 2)                       = 2
read(3, "r sub_pos -1  ", 14)           = 14
read(3, "  ", 2)                        = 2
read(3, "        # mov", 13)            = 13
read(3, "e ", 2)                        = 2
read(3, "subtitles up\nt sub_pos +1       "..., 62) = 62
read(3, "su", 2)                        = 2
read(3, "b_step +1\t\t# immediately display"..., 63) = 63
read(3, "# ", 2)                        = 2
read(3, "           ", 11)              = 11
read(3, "  ", 2)                        = 2
read(3, "       previous\n#? sub_scale +0."..., 82) = 82
read(3, "# ", 2)                        = 2
read(3, "decrease subtitle font size\nf vo"..., 42) = 42
read(3, "n\n", 2)                       = 2
read(3, "T vo_ontop              # toggle"..., 44) = 44
read(3, "w ontop of other windows\nw pansc"..., 52) = 52
read(3, "oom out with -panscan 0 -fs\ne pa"..., 47) = 47
read(3, "     #      in\nc capturing      "..., 48) = 48
read(3, "nd append) file/stream to stream"..., 48) = 48
read(3, "ur", 2)                        = 2
read(3, "e\ns screenshot", 14)          = 14
read(3, "  ", 2)                        = 2
read(3, "          # take a png screensho"..., 67) = 67
read(3, "  ", 2)                        = 2
read(3, "         # S will take a png scr"..., 53) = 53
read(3, "e\n", 2)                       = 2
read(3, "\nh tv_step_channel 1\nl tv_step_c", 32) = 32
read(3, "ha", 2)                        = 2
read(3, "nnel -1\nn tv_step_norm\nb tv_step"..., 83) = 83
read(3, "ic", 2)                        = 2
read(3, "k support has to be explicitly e"..., 66) = 66
read(3, "with --enable-joystick\n##\n\nJOY_R"..., 70) = 70
read(3, "see", 3)                       = 3
read(3, "k 60\nJOY_DOWN seek", 18)      = 18
read(3, " -", 2)                        = 2
read(3, "60\nJOY_BTN0 pause\nJ", 19)    = 19
read(3, "OY", 2)                        = 2
read(3, "_BTN1 osd\nJOY", 13)           = 13
read(3, "_B", 2)                        = 2
read(3, "TN2 volume 1\nJOY_", 17)       = 17
read(3, "B", 1)                         = 1
read(3, "TN3", 3)                       = 3
read(3, " volume -1\nJOY_BTN4 ", 20)    = 20
read(3, "set_menu main\n\n##\n## Apple Remot"..., 61) = 61
read(3, "nu with Apple Remote, set key AR"..., 47) = 47
read(3, "D m", 3)                       = 3
read(3, "enu command", 11)              = 11
read(3, ",\n## or ", 8)                 = 8
read(3, "just comm", 9)                 = 9
read(3, "ent out t", 9)                 = 9
read(3, "he 'AR_", 7)                   = 7
read(3, "MENU osd", 8)                  = 8
read(3, "' line an", 9)                 = 9
read(3, "d uncomme", 9)                 = 9
read(3, "nt the li", 9)                 = 9
read(3, "ne aft", 6)                    = 6
read(3, "er it.\n##", 9)                = 9
read(3, "\n\nAR", 4)                    = 4
read(3, "_PLAY pau", 9)                 = 9
read(3, "se\nAR_PLA", 9)                = 9
read(3, "Y_HOLD qu", 9)                 = 9
read(3, "it\nAR_NEXT", 10)              = 10
read(3, " seek 30\n", 9)                = 9
read(3, "AR_NEXT_HOLD s", 14)           = 14
read(3, "e", 1)                         = 1
read(3, "ek ", 3)                       = 3
read(3, "120\nAR_PREV seek -10\nAR_", 24) = 24
read(3, "PRE", 3)                       = 3
read(3, "V_HOLD seek -120\nAR_MENU menu up"..., 79) = 79
read(3, "volume 1\nAR_VDOWN volume -1\n\n##\n"..., 79) = 79
read(3, "g o", 3)                       = 3
read(3, "nly the k", 9)                 = 9
read(3, "eyboar", 6)                    = 6
read(3, "d it is enoug", 13)            = 13
read(3, "h to ", 5)                     = 5
read(3, "define o", 8)                  = 8
read(3, "ne comma", 8)                  = 8
read(3, "nd (like\n## \"", 13)          = 13
read(3, "menu up\")", 9)                = 9
read(3, ", becaus", 8)                  = 8
read(3, "e then th", 9)                 = 9
read(3, "at single key", 13)            = 13
read(3, " will disp", 10)               = 10
read(3, "lay the ", 8)                  = 8
read(3, "menu, wh", 8)                  = 8
read(3, "ich can\n## then be na", 21)   = 21
read(3, "vigated with ", 13)            = 13
read(3, "the c", 5)                     = 5
read(3, "ursor k", 7)                   = 7
read(3, "eys and E", 9)                 = 9
read(3, "NTER (def", 9)                 = 9
read(3, "ined in me", 10)               = 10
read(3, "n", 1)                         = 1
read(3, "u.c", 3)                       = 3
read(3, "onf).\n##\n## LIRC users sho", 26) = 26
read(3, "uld", 3)                       = 3
read(3, " bind each \"menu\" command to a b"..., 79) = 79
read(3, "nd directly displays the (sub)me"..., 77) = 77
read(3, " be self-explanatory (although n"..., 76) = 76
read(3, "put", 3)                       = 3
read(3, ".conf.\n##\n\n#MOUSE_BTN0 menu up\n#"..., 75) = 75
read(3, "nu ", 3)                       = 3
read(3, "hide\n#y set_menu general_pref\n\n#"..., 69) = 69
read(3, "\nUP    {dvdnav} dvdnav up       "..., 71) = 71
read(3, "wn        # DVDNav DOWN\nLEFT  {d"..., 44) = 44
read(3, "v l", 3)                       = 3
read(3, "e", 1)                         = 1
read(3, "ft        # DVDNav L", 20)     = 20
read(3, "EFT\nRIGHT {dv", 13)           = 13
read(3, "dnav} dvdna", 11)              = 11
read(3, "v right       #", 15)          = 15
read(3, " DVDNav RIGHT", 13)            = 13
read(3, "\nESC   {dvdnav} dvdnav me", 25) = 25
read(3, "n", 1)                         = 1
read(3, "u  ", 3)                       = 3
read(3, "      # DV", 10)               = 10
read(3, "DNav MENU\nENTER {dvdna", 22)  = 22
read(3, "v} ", 3)                       = 3
read(3, "dvdn", 4)                      = 4
read(3, "av select      # DVDNav SELECT ("..., 43) = 43
read(3, "dvdna", 5)                     = 5
read(3, "v} dvdnav prev        # DVDNav P"..., 43) = 43
read(3, "u (in", 5)                     = 5
read(3, " the order chapter->title->root)"..., 43) = 43
read(3, " {dvdn", 6)                    = 6
read(3, "av} dvdnav up      # DVDNav UP\nA"..., 43) = 43
read(3, "vdna", 4)                      = 4
read(3, "v} dvdnav down    # DVDNav DOWN\n"..., 44) = 44
read(3, "vdnav}", 6)                    = 6
read(3, " dvdnav left    # DVDNav LEFT\nAR"..., 49) = 49
read(3, "dvd", 3)                       = 3
read(3, "nav right   # DVDNav RIGHT\nAR_ME"..., 90) = 90
read(3, "av} dvdn", 8)                  = 8
read(3, "av select  # DVDNav SELECT (ok)\n"..., 39) = 39
read(3, "k_chapter", 9)                 = 9
read(3, " -1      # skip to previous dvd "..., 39) = 39
read(3, "\n#? seek", 8)                 = 8
read(3, "_chapter +1      #         next\n"..., 40) = 40
read(3, "dvanced ", 8)                  = 8
read(3, "seek\n## Uncomment the following "..., 41) = 41
read(3, "be able ", 8)                  = 8
read(3, "to seek to n% of the media with\n"..., 40) = 40
read(3, "x keys.\n", 8)                 = 8
read(3, "##\n#F1 seek 10 1\n#F2 seek 20 1\n#"..., 47) = 47
read(3, "4", 1)                         = 1
read(3, " seek 40 1\n#F5 seek 50 1\n#F6 see"..., 55) = 55
read(3, "8 seek 80 1\n#F9 seek 90 1\n", 39) = 26
read(3, "", 13)                         = 0
close(3)                                = 0
open("/dev/input/js0", O_RDONLY|O_NONBLOCK) = -1 ENOENT (No such file or directory)
write(2, "Can't open joystick device /dev/"..., 69Can't open joystick device /dev/input/js0: No such file or directory
) = 69
write(2, "Can't init input joystick\n", 26Can't init input joystick
) = 26
socket(PF_FILE, SOCK_STREAM, 0)         = 3
connect(3, {sa_family=AF_FILE, path="/var/run/lirc/lircd"}, 110) = -1 ENOENT (No such file or directory)
close(3)                                = 0
write(2, "mplayer: could not connect to so"..., 37mplayer: could not connect to socket
) = 37
write(2, "mplayer: No such file or directo"..., 35mplayer: No such file or directory
) = 35
write(2, "Failed to open LIRC support. You"..., 78Failed to open LIRC support. You will not be able to use your remote control.
) = 78
rt_sigaction(SIGCHLD, {0x7ff24c0a9180, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGTERM, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGHUP, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGINT, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGQUIT, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGPIPE, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGBUS, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGSEGV, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGILL, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGFPE, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
rt_sigaction(SIGABRT, {0x7ff24c0a9040, [], SA_RESTORER|SA_INTERRUPT|SA_NODEFER|SA_RESETHAND, 0x7ff24122f250}, {SIG_DFL, [], 0}, 8) = 0
stat("/home/sesse/.mplayer/@239.1.1.20:1234.conf", 0x7fffb7532670) = -1 ENOENT (No such file or directory)
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a3b, c_line=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a3b, c_line=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
ioctl(0, SNDCTL_TMR_START or TCSETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a31, c_line=0, c_cc[VMIN]=1, c_cc[VTIME]=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a31, c_line=0, c_cc[VMIN]=1, c_cc[VTIME]=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
write(1, "\nPlaying udp://@239.1.1.20:1234."..., 33
Playing udp://@239.1.1.20:1234.
) = 33
open("udp://@239.1.1.ifo", O_RDONLY)    = -1 ENOENT (No such file or directory)
open("udp://@239.1.1.idx", O_RDONLY)    = -1 ENOENT (No such file or directory)
open("/home/sesse/.mplayer/sub/@239.1.1.ifo", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/home/sesse/.mplayer/sub/@239.1.1.idx", O_RDONLY) = -1 ENOENT (No such file or directory)
write(1, "STREAM_UDP, URL: udp://@239.1.1."..., 40STREAM_UDP, URL: udp://@239.1.1.20:1234
) = 40
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(1234), sin_addr=inet_addr("239.1.1.20")}, 16) = 0
setsockopt(3, SOL_SOCKET, SO_RCVBUF, [245760], 4) = 0
setsockopt(3, SOL_IP, IP_ADD_MEMBERSHIP, "\357\1\1\24\0\0\0\0", 8) = 0
select(4, [3], NULL, NULL, {1, 0})      = 0 (Timeout)
write(2, "Timeout! No data from host 239.1"..., 38Timeout! No data from host 239.1.1.20
) = 38
close(3)                                = 0
write(2, "udp_streaming_start failed\n", 27udp_streaming_start failed
) = 27
write(2, "No stream found to handle url ud"..., 53No stream found to handle url udp://@239.1.1.20:1234
) = 53
select(1, [0], NULL, NULL, {0, 0})      = 0 (Timeout)
write(1, "\n", 1
)                       = 1
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a31, c_line=0, c_cc[VMIN]=1, c_cc[VTIME]=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
ioctl(0, SNDCTL_TMR_START or TCSETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a3b, c_line=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {c_iflags=0x2504, c_oflags=0x5, c_cflags=0xbf, c_lflags=0x8a3b, c_line=0, c_cc="\x03\x1c\x7f\x15\x04\x00\x01\x00\x11\x13\x1a\x00\x12\x0f\x17\x16\x00\x00\x00"}) = 0
write(1, "\nExiting... (End of file)\n", 26
Exiting... (End of file)
) = 26
getpid()                                = 23881
exit_group(0)                           = ?

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="igmp.txt"

Idx	Device    : Count Querier	Group    Users Timer	Reporter
1	lo        :     1      V3
				010000E0     1 0:00000000		0
2	eth0      :     1      V3
				010000E0     1 0:00000000		0
3	wlan0     :     1      V3
				010000E0     1 0:00000000		0
4	br0       :     2      V3
				FB0000E0     1 0:00000000		0
				010000E0     1 0:00000000		0
5	eth0.11   :     2      V3
				FAFFFFEF     1 0:00000000		0
				010000E0     1 0:00000000		0
6	eth0.10   :     1      V3
				010000E0     1 0:00000000		0
9	k_altersex:     1      V3
				010000E0     1 0:00000000		0
10	eth0.2    :     2      V2
				FB0000E0     1 0:00000000		1
				010000E0     1 0:00000000		0
11	eth0.3    :     2      V3
				FB0000E0     1 0:00000000		0
				010000E0     1 0:00000000		0
13	he-ipv6   :     1      V3
				010000E0     1 0:00000000		0
14	bablefisk :     1      V3
				010000E0     1 0:00000000		0
15	k_molvenfinnoy:     1      V3
				010000E0     1 0:00000000		0
16	k_trygve  :     1      V3
				010000E0     1 0:00000000		0
17	k_pannekake:     1      V3
				010000E0     1 0:00000000		0
18	k_wikene  :     1      V3
				010000E0     1 0:00000000		0
19	k_magne   :     1      V3
				010000E0     1 0:00000000		0
20	k_molven  :     1      V3
				010000E0     1 0:00000000		0
21	k_berge   :     1      V3
				010000E0     1 0:00000000		0

--FCuugMFkClbJLl1L--
