From: <Jayakrishnan.Chathu@nokia.com>
Subject: RE: WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Tue, 8 Jan 2008 12:36:46 -0600
Message-ID: <2198383E1141814486F0B881B3260CF501D6BD24@daebe103.NOE.Nokia.com>
References: <4782CD50.90006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:46824 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbYAHSh1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 13:37:27 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4782CD50.90006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is an embedded system, With a small file system and 2.6.23 kernel.
There are no link-monitoring tool running.  I will
Try to reproduce with 2.6.24-rc7. 

Chathu

-----Original Message-----
From: ext Kok, Auke [mailto:auke-jan.h.kok@intel.com] 
Sent: Monday, January 07, 2008 5:10 PM
To: Chathu Jayakrishnan (Nokia-S&S/MtView)
Cc: linux-kernel@vger.kernel.org; NetDev
Subject: Re: WARNING: at kernel/softirq.c:139 local_bh_enable()

Jayakrishnan.Chathu@nokia.com wrote:
> I am running 2.6.23 kernel on a DUAL core and QUAD core i386 boxes and

> after everyboot, when the ethernet traffic starts i get this warning.
> 
> All the ports in the system are e1000 and i am using the kernel e1000 
> driver.

[added netdev to the Cc:]

can you repro this with 2.6.24-rc7? What distro are you using? Is your
distro running a link-monitoring tool of some sorts?

Auke



> 
> Jan  7 22:31:00 localhost [warning] WARNING: at kernel/softirq.c:139
> local_bh_enable()
> Jan  7 22:31:00 localhost [warning] [<c012bd0f>]
> local_bh_enable+0x49/0xa9
> Jan  7 22:31:00 localhost [warning] [<c039ba1a>]
> dev_queue_xmit+0x26c/0x275
> Jan  7 22:31:00 localhost [warning] [<c03cdf6c>] arp_xmit+0x4d/0x51 
> Jan  7 22:31:00 localhost [warning] [<c03cd9f6>] 
> arp_solicit+0x156/0x174
> 
> Jan  7 22:31:00 localhost [warning] [<c03a047f>]
> neigh_timer_handler+0x1e0/0x224
> Jan  7 22:31:00 localhost [warning] [<c012f820>]
> run_timer_softirq+0x113/0x172
> Jan  7 22:31:00 localhost [warning] [<c013b042>] WARNING: at
> kernel/softirq.c:139 local_bh_enable() Jan  7 22:31:00 localhost 
> [warning] hrtimer_interrupt+0x19c/0x1c4 Jan  7 22:31:00 localhost 
> [warning] [<c014002a>]  [<c012bd0f>]
> local_bh_enable+0x49/0xa9
> Jan  7 22:31:00 localhost [warning] [<c039ba1a>]
> dev_queue_xmit+0x26c/0x275
> Jan  7 22:31:00 localhost [warning] [<c03a0c05>] 
> neigh_resolve_output+0x12c/0x15e Jan  7 22:31:00 localhost [warning] 
> [<c03a0881>] neigh_update+0x246/0x2cb Jan  7 22:31:00 localhost 
> [warning] [<c039fb21>] neigh_lookup+0xa9/0xb3 Jan  7 22:31:00 
> localhost [warning] [<c03ce410>] arp_process+0x43c/0x477
> 
> Jan  7 22:31:00 localhost [warning] [<c0120b73>] 
> enqueue_task_fair+0x2d/0x30 Jan  7 22:31:00 localhost [warning] 
> tick_sched_timer+0x0/0xba Jan  7 22:31:00 localhost [warning] 
> [<c03ce554>] arp_rcv+0x104/0x119 Jan  7 22:31:00 localhost [warning] 
> [<c03a029f>]  [<c039bda6>] netif_receive_skb+0x1c5/0x1de Jan  7 
> 22:31:00 localhost [warning] [<f897a61d>] 
> e1000_clean_rx_irq+0x40e/0x4ca [e1000] Jan  7 22:31:00 localhost 
> [warning] [<c013bdc6>]
> getnstimeofday+0x36/0x10c
> Jan  7 22:31:00 localhost [warning] neigh_timer_handler+0x0/0x224 Jan

> 7 22:31:00 localhost [warning] [<c012be12>] __do_softirq+0x60/0xc1 Jan

> 7 22:31:00 localhost [warning] [<f8979e34>] e1000_clean+0x74/0x119 
> [e1000] Jan  7 22:31:00 localhost [warning] [<c039bf03>]  [<c012bea4>]
> net_rx_action+0x5a/0xd3
> Jan  7 22:31:00 localhost [warning] [<c012be12>] 
> __do_softirq+0x60/0xc1 Jan  7 22:31:00 localhost [warning] 
> do_softirq+0x31/0x35 Jan  7 22:31:00 localhost [warning] [<c012bea4>] 
> do_softirq+0x31/0x35 Jan  7 22:31:00 localhost [warning] [<c012bf03>] 
> irq_exit+0x38/0x6b Jan  7 22:31:00 localhost [warning] [<c0106a1e>]  
> [<c012bf03>]
> do_IRQ+0x80/0x93
> Jan  7 22:31:00 localhost [warning] irq_exit+0x38/0x6b Jan  7 22:31:00

> localhost [warning] [<c01057b7>]
> common_interrupt+0x23/0x28
> Jan  7 22:31:00 localhost [warning] [<c01600d8>]  [<c011a34d>]
> get_swap_page+0xe7/0x215
> Jan  7 22:31:00 localhost [warning] [<c0103232>]
> mwait_idle_with_hints+0x34/0x38 Jan  7 22:31:00 localhost [warning] 
> [<c0103236>] mwait_idle+0x0/0xa Jan  7 22:31:00 localhost [warning] 
> [<c01030f2>] cpu_idle+0x98/0xb9 Jan  7 22:31:00 localhost [warning] 
> smp_apic_timer_interrupt+0x2c/0x35
> Jan  7 22:31:00 localhost [warning] ======================= Jan  7 
> 22:31:00 localhost [warning] [<c0105874>] 
> apic_timer_interrupt+0x28/0x30 Jan  7 22:31:00 localhost [warning] 
> [<c01600d8>]
> get_swap_page+0xe7/0x215
> Jan  7 22:31:00 localhost [warning] [<c0103232>]
> mwait_idle_with_hints+0x34/0x38
> Jan  7 22:31:00 localhost [warning] [<c0103236>] mwait_idle+0x0/0xa 
> Jan  7 22:31:00 localhost [warning] [<c01030f2>] cpu_idle+0x98/0xb9 
> Jan  7 22:31:00 localhost [warning] =======================
> 
> 
> Thanks
> Jayakrishnan Chathu
> --
> To unsubscribe from this list: send the line "unsubscribe
linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

