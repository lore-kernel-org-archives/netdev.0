From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: eth1: Detected Hardware Unit Hang
Date: Mon, 29 Mar 2010 17:33:39 +0200
Message-ID: <4BB0C853.2080607@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:58662 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753745Ab0C2Pdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 11:33:44 -0400
Received: from unknown (HELO [192.168.1.101]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp2.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 29 Mar 2010 15:33:42 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After update to kernel from 2.6.29.1 to 2.6.33.1 i have this info in dmesg:

0000:05:00.0: eth1: Detected Hardware Unit Hang:
   TDH <1e>
   TDT <a>
   next_to_use <a>
   next_to_clean <1d>
buffer_info[next_to_clean]:
   time_stamp <33bae15>
   next_to_watch <20>
   jiffies <33bafaf>
   next_to_watch.status <0>
MAC Status <80080783>
PHY Status <796d>
PHY 1000BASE-T Status <3800>
PHY Extended Status <3000>
PCI Status <10>
0000:05:00.0: eth1: Detected Hardware Unit Hang:
   TDH <1e>
   TDT <a>
   next_to_use <a>
   next_to_clean <1d>
buffer_info[next_to_clean]:
   time_stamp <33bae15>
   next_to_watch <20>
   jiffies <33bb1a3>
   next_to_watch.status <0>
MAC Status <80080783>
PHY Status <796d>
PHY 1000BASE-T Status <3800>
PHY Extended Status <3000>
PCI Status <10>
0000:05:00.0: eth1: Detected Hardware Unit Hang:
   TDH <1e>
   TDT <a>
   next_to_use <a>
   next_to_clean <1d>
buffer_info[next_to_clean]:
   time_stamp <33bae15>
   next_to_watch <20>
   jiffies <33bb397>
   next_to_watch.status <0>
MAC Status <80080783>
PHY Status <796d>
PHY 1000BASE-T Status <3800>
PHY Extended Status <3000>
PCI Status <10>
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x118/0x19c()
Hardware name: X7DCT
NETDEV WATCHDOG: eth1 (e1000e): transmit queue 0 timed out
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.33.1 #2
Call Trace:
  [<c1024e3d>] ? warn_slowpath_common+0x52/0x71
  [<c1024e49>] ? warn_slowpath_common+0x5e/0x71
  [<c1024e8e>] ? warn_slowpath_fmt+0x26/0x2a
  [<c1261f54>] ? dev_watchdog+0x118/0x19c
  [<c102135c>] ? __wake_up+0x29/0x39
  [<c10320c6>] ? insert_work+0x40/0x44
  [<c1261e3c>] ? dev_watchdog+0x0/0x19c
  [<c102cc15>] ? run_timer_softirq+0x11a/0x173
  [<c1028e5b>] ? __do_softirq+0x74/0xdf
  [<c1028ee9>] ? do_softirq+0x23/0x27
  [<c10290be>] ? irq_exit+0x26/0x58
  [<c10102d7>] ? smp_apic_timer_interrupt+0x6c/0x76
  [<c12c5f9a>] ? apic_timer_interrupt+0x2a/0x30
  [<c1007e06>] ? mwait_idle+0x49/0x4e
  [<c10017e8>] ? cpu_idle+0x41/0x5a
---[ end trace bcca9926a046332c ]---


With kernel 2.6.29.1 all was ok.
