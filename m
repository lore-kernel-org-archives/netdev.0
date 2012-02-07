From: Naresh Bhat <nareshgbhat@gmail.com>
Subject: x86_64 arch+SMP ON+linux-2.6.32.46+E1000+KGDBOE = Timed out. Ignoring
 packet error, continuing...
Date: Tue, 7 Feb 2012 21:43:51 +0530
Message-ID: <CAJXQGfJKdDTC4Wn4d7LTwpxSnpZ3iokOX+Sy1oc3LXGjZkJ6VA@mail.gmail.com>
References: <CAJXQGfJkmTZHDVPP_Rw7W3j8nmxXTN_OLUxjzCt-UOLGx61CZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43636 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab2BGQNw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 11:13:52 -0500
In-Reply-To: <CAJXQGfJkmTZHDVPP_Rw7W3j8nmxXTN_OLUxjzCt-UOLGx61CZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying KGDBOE on the following kernel

Kernel    -   linux-2.6.32.46 (With SMP set)
Hardware -  x86 64bit machine (Intel Nehlaum)
Ethernet   - E1000 driver is used

But I am getting the following error

........
............
.................
Breakpoint 2, sys_sync () at fs/sync.c:130
130        wakeup_flusher_threads(0);
(gdb) s
wakeup_flusher_threads (nr_pages=0) at fs/fs-writeback.c:1005
1005    {
(gdb) s

Ignoring packet error, continuing...
Ignoring packet error, continuing...
Ignoring packet error, continuing...


Detailed logs with debug set :
-----------------------------------------

...................
................................
.......................................
Sending packet: $z0,ffffffff810ad687,1#66...Ack
Packet received: OK
target_remove_breakpoint (0x810ad687, xxx) = 0
target_terminal_ours ()
kgdb_register_io_module (new_kgdb_io_ops=0xffffffff81a9d5b0) at
kernel/kgdb.c:1778
1778    }
(gdb) n
Sending packet: $Z0,ffffffff810ad687,1#46...Ack
Packet received: OK
target_insert_breakpoint (0x810ad687, xxx) = 0
target_terminal_inferior ()
Sending packet: $s#73...Ack
target_resume (-1, step, 0)
Packet received: T05thread:0000000000000001;
target_wait (-1, status) = 42000,   status->kind = stopped, signal = SIGTRAP
target_thread_architecture (Thread 1) = 0xa2e45c0 [i386:x86-64]
Sending packet: $g#67...Ack
Packet received:
0000000000000000b0d5a981ffffffffffffffff00000000ffffffff0000000086020000000000004602000000000000b07e0b2f0088ffffa87e0b2f0088ffff000000000000000058f8b081ffffffff507d0b2f0088ffff18b20681ffffffff000000000000000008000000000000000800000000000000b0610300000000005cda0a81ffffffff820300001000000018000000
target_fetch_registers (rip) = 5cda0a81ffffffff 0xffffffff810ada5c -2129995172
target_stopped_by_watchpoint () = 0
target_terminal_inferior ()
Sending packet: $s#73...Ack
target_resume (-1, step, 0)
Packet received: T05thread:0000000000000001;
target_wait (-1, status) = 42000,   status->kind = stopped, signal = SIGTRAP
target_thread_architecture (Thread 1) = 0xa2e45c0 [i386:x86-64]
Sending packet: $g#67...Ack
Packet received:
00000000000000000000000000000000ffffffff00000000ffffffff0000000086020000000000004602000000000000b07e0b2f0088ffffb07e0b2f0088ffff000000000000000058f8b081ffffffff507d0b2f0088ffff18b20681ffffffff000000000000000008000000000000000800000000000000b0610300000000005dda0a81ffffffff820300001000000018000000
target_fetch_registers (rip) = 5dda0a81ffffffff 0xffffffff810ada5d -2129995171
target_stopped_by_watchpoint () = 0
target_terminal_inferior ()
Sending packet: $s#73...Ack
target_resume (-1, step, 0)
Packet received: T05thread:0000000000000001;
target_wait (-1, status) = 42000,   status->kind = stopped, signal = SIGTRAP
target_thread_architecture (Thread 1) = 0xa2e45c0 [i386:x86-64]
Sending packet: $g#67...Ack
Packet received:
00000000000000000000000000000000ffffffff00000000ffffffff0000000086020000000000004602000000000000c07e0b2f0088ffffb87e0b2f0088ffff000000000000000058f8b081ffffffff507d0b2f0088ffff18b20681ffffffff000000000000000008000000000000000800000000000000b0610300000000005eda0a81ffffffff820300001000000018000000
target_fetch_registers (rip) = 5eda0a81ffffffff 0xffffffff810ada5e -2129995170
target_stopped_by_watchpoint () = 0
target_terminal_inferior ()
Sending packet: $s#73...Ack
target_resume (-1, step, 0)
Packet received: T05thread:0000000000000001;
target_wait (-1, status) = 42000,   status->kind = stopped, signal = SIGTRAP
target_thread_architecture (Thread 1) = 0xa2e45c0 [i386:x86-64]
Sending packet: $g#67...Ack
Packet received:
00000000000000000000000000000000ffffffff00000000ffffffff0000000086020000000000004602000000000000c07e0b2f0088ffffc07e0b2f0088ffff000000000000000058f8b081ffffffff507d0b2f0088ffff18b20681ffffffff000000000000000008000000000000000800000000000000b061030000000000180d3e81ffffffff820300001000000018000000
target_fetch_registers (rip) = 180d3e81ffffffff 0xffffffff813e0d18 -2126639848
target_stopped_by_watchpoint () = 0
target_terminal_ours_for_output ()
Sending packet: $mffffffff813e0d18,1#f8...Ack
Packet received: 85
remote:target_xfer_partial (2, (null), 0xbfe00edb, 0x0,
0xffffffff813e0d18, 1) = 1, bytes = 85
Sending packet: $mffffffff813e0d18,1#f8...Ack
Packet received: 85
remote:target_xfer_partial (2, (null), 0xbfe00edb, 0x0,
0xffffffff813e0d18, 1) = 1, bytes = 85
Sending packet: $mffff88002f0b7ec0,40#be...Ack
Packet received:
e07e0b2f0088ffff510d3e81ffffffff0800000000000000380d3e81ffffffff107f0b2f0088ffff5fa00081ffffffff107f0b2f0088ffffb0bcb881ffffffff
remote:target_xfer_partial (3, (null), 0xa944050, 0x0,
0xffff88002f0b7ec0, 64) = 64, bytes =
 e0 7e 0b 2f 00 88 ff ff 51 0d 3e 81 ff ff ff ff ...
remote:target_xfer_partial (4, (null), 0xa944030, 0x0,
0xffff88002f0b7ec8, 8) = 8, bytes =
 51 0d 3e 81 ff ff ff ff
remote:target_xfer_partial (4, (null), 0xa944030, 0x0,
0xffff88002f0b7ec0, 8) = 8, bytes =
 e0 7e 0b 2f 00 88 ff ff
target_terminal_inferior ()
Sending packet: $s#73...Ack
target_resume (-1, step, 0)
Packet received: T05thread:0000000000000001;
target_wait (-1, status) = 42000,   status->kind = stopped, signal = SIGTRAP
target_thread_architecture (Thread 1) = 0xa2e45c0 [i386:x86-64]
Sending packet: $g#67...Ack
Packet received:
00000000000000000000000000000000ffffffff00000000ffffffff0000000086020000000000004602000000000000c07e0b2f0088ffffc07e0b2f0088ffff000000000000000058f8b081ffffffff507d0b2f0088ffff18b20681ffffffff000000000000000008000000000000000800000000000000b0610300000000001a0d3e81ffffffff460300001000000018000000
target_fetch_registers (rip) = 1a0d3e81ffffffff 0xffffffff813e0d1a -2126639846
target_stopped_by_watchpoint () = 0
target_terminal_inferior ()
Sending packet: $s#73...Ack
target_resume (-1, step, 0)
Packet received: T05thread:0000000000000001;
target_wait (-1, status) = 42000,   status->kind = stopped, signal = SIGTRAP
target_thread_architecture (Thread 1) = 0xa2e45c0 [i386:x86-64]
Sending packet: $g#67...Sending packet: $g#67...Sending packet:
$g#67...Sending packet: $g#67...Timed out.
Timed out.
Timed out.
Ignoring packet error, continuing...
Bad register packet; fetching a new packet
Timed out.
Timed out.
Timed out.
Ignoring packet error, continuing...
Bad register packet; fetching a new packet
Timed out.
Timed out.
Timed out.
Ignoring packet error, continuing...
Bad register packet; fetching a new packet
Timed out.
..........................
.................................


Please help me to identify any available patch in kernel.org or any
guidance to fix the above error.  I will really appreciate your help
on this.


-- Thanks and Regards
"For things to change, we must change"
-Naresh Bhat
