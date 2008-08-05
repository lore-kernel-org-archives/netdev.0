From: "Jaswinder Singh" <jaswinderlinux@gmail.com>
Subject: BUG: fealnx in 2.6.27-rc1
Date: Tue, 5 Aug 2008 20:16:28 +0530
Message-ID: <3f9a31f40808050746r1b35799am8bf0e4a637069fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:60825 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026AbYHEOq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 10:46:29 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1811714waf.23
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 07:46:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eth0: no IPv6 routers present
NETDEV WATCHDOG: eth0 (fealnx): transmit timed out
eth0: Transmit timed out, status 00000000, resetting...
  Rx ring f7b56000:  80000000 80000000 80000000 80000000 80000000
80000000 80000000 80000000 80000000 80000000 80000000 80000000
  Tx ring f7b57000:  0000 80000000 80000000 80000000 80000000 80000000
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:221 dev_watchdog+0x109/0x181()
Modules linked in:
Pid: 4, comm: ksoftirqd/0 Not tainted 2.6.27-rc1 #109
 [<c011c26a>] warn_on_slowpath+0x40/0x63
 [<c0132f1a>] tick_program_event+0x2b/0x4a
 [<c012df6e>] hrtimer_interrupt+0x13a/0x162
 [<c010f291>] smp_apic_timer_interrupt+0x6c/0x76
 [<c010359c>] apic_timer_interrupt+0x28/0x30
 [<c03ab466>] _spin_unlock_irqrestore+0x4/0x1a
 [<c02720f1>] tx_timeout+0x189/0x1c5
 [<c032b306>] dev_watchdog+0x109/0x181
 [<c01235c0>] __mod_timer+0x8e/0x97
 [<c03264cc>] neigh_periodic_timer+0x14a/0x158
 [<c032b1fd>] dev_watchdog+0x0/0x181
 [<c01230e2>] run_timer_softirq+0x123/0x17b
 [<c011fff9>] __do_softirq+0x6f/0xd2
 [<c012008e>] do_softirq+0x32/0x36
 [<c0120109>] ksoftirqd+0x77/0x128
 [<c0120092>] ksoftirqd+0x0/0x128
 [<c012af79>] kthread+0x38/0x5d
 [<c012af41>] kthread+0x0/0x5d
 [<c01036df>] kernel_thread_helper+0x7/0x10
 =======================
---[ end trace 090ebc3b866eecff ]---
