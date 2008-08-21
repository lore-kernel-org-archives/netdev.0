From: adobriyan@gmail.com
Subject: atl1: WARNING at net/sched/sch_generic.c:221
Date: Thu, 21 Aug 2008 15:58:49 +0400
Message-ID: <20080821115849.GA2126@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jcliburn@gmail.com, csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:33606 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330AbYHUL51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 07:57:27 -0400
Received: by gv-out-0910.google.com with SMTP id e6so119101gvc.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 04:57:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message happens more or less every reboot, sometimes cable unplug/plug is needed
to restore connectivity, otherwise card is working fine.


[   22.570010] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
[   26.570011] NET: Registered protocol family 10
[   37.551934] eth0: no IPv6 routers present

	[rebooted box which is directly connected to a box with atl1]

[ 2078.740004] atl1 0000:03:00.0: eth0 link is down
[ 2080.790004] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex
[ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out
[ 2086.050004] ------------[ cut here ]------------
[ 2086.050004] WARNING: at net/sched/sch_generic.c:221 dev_watchdog+0x205/0x220()
[ 2086.050004] Modules linked in: ipv6 ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 xt_state nf_conntrack iptable_filter ip_tables x_tables
[ 2086.052503] Pid: 0, comm: swapper Not tainted 2.6.27-rc4-netns-nf #4
[ 2086.052503] 
[ 2086.052503] Call Trace:
[ 2086.052503]  <IRQ>  [<ffffffff8023455f>] warn_on_slowpath+0x5f/0x80
[ 2086.052503]  [<ffffffff80259c00>] ? trace_hardirqs_on_caller+0x130/0x160
[ 2086.052503]  [<ffffffff80259b61>] ? trace_hardirqs_on_caller+0x91/0x160
[ 2086.052503]  [<ffffffff80259c3d>] ? trace_hardirqs_on+0xd/0x10
[ 2086.052503]  [<ffffffff80431ab5>] ? _spin_unlock_irqrestore+0x75/0x80
[ 2086.052503]  [<ffffffff8024676c>] ? __queue_work+0x3c/0x50
[ 2086.052503]  [<ffffffff80246814>] ? queue_work_on+0x44/0x60
[ 2086.052503]  [<ffffffff80246993>] ? queue_work+0x53/0x60
[ 2086.052503]  [<ffffffff803d4c35>] dev_watchdog+0x205/0x220
[ 2086.052503]  [<ffffffff80259c3d>] ? trace_hardirqs_on+0xd/0x10
[ 2086.052503]  [<ffffffff80259b61>] ? trace_hardirqs_on_caller+0x91/0x160
[ 2086.052503]  [<ffffffff803d4a30>] ? dev_watchdog+0x0/0x220
[ 2086.052503]  [<ffffffff8023eacc>] run_timer_softirq+0x18c/0x200
[ 2086.052503]  [<ffffffff80239e67>] __do_softirq+0x67/0xe0
[ 2086.052503]  [<ffffffff8020cc4c>] call_softirq+0x1c/0x30
[ 2086.052503]  [<ffffffff8020f2b5>] do_softirq+0x65/0xa0
[ 2086.052503]  [<ffffffff80239cf9>] irq_exit+0x99/0xb0
[ 2086.052503]  [<ffffffff8021d187>] smp_apic_timer_interrupt+0x97/0xf0
[ 2086.052503]  [<ffffffff8020c69b>] apic_timer_interrupt+0x6b/0x70
[ 2086.052503]  <EOI>  [<ffffffff802136ec>] ? mwait_idle+0x4c/0x60
[ 2086.052503]  [<ffffffff802136e3>] ? mwait_idle+0x43/0x60
[ 2086.052503]  [<ffffffff8020a276>] ? cpu_idle+0x46/0x90
[ 2086.052503]  [<ffffffff804266d0>] ? rest_init+0x70/0x80
[ 2086.052503] 
[ 2086.052503] ---[ end trace 4ccf372e8f6b84c3 ]---
[ 2086.070003] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex
[ 2090.390003] atl1 0000:03:00.0: eth0 link is down
[ 2092.550003] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex

