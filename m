From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [Bugme-new] [Bug 12086] New: NETDEV WATCHDOG: eth0 (atl1):
 transmit timed out
Date: Mon, 24 Nov 2008 15:32:47 -0600
Message-ID: <20081124153247.38b80731@osprey.hogchain.net>
References: <bug-12086-10286@http.bugzilla.kernel.org/>
	<20081122205803.517ad692.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	bharattharee@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:39964 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbYKXVcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:32:51 -0500
In-Reply-To: <20081122205803.517ad692.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Nov 2008 20:58:03 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:


> > Call Trace:
> >  <IRQ>  [<ffffffff8103bb01>] warn_slowpath+0xae/0xd7
> >  [<ffffffff810b3522>] ? virt_to_head_page+0x31/0x41
> >  [<ffffffff810b4df2>] ? kmem_cache_free+0x99/0xb8
> >  [<ffffffff810b3522>] ? virt_to_head_page+0x31/0x41
> >  [<ffffffff81138b0b>] ? blk_remove_plug+0x71/0xa5
> >  [<ffffffff81135d3f>] ? elv_queue_empty+0x22/0x24
> >  [<ffffffff81138dc2>] ? blk_run_queue+0x30/0x35
> >  [<ffffffffa005c4fa>] ? scsi_run_queue+0x29f/0x2d2 [scsi_mod]
> >  [<ffffffff81053d42>] ? sched_clock_cpu+0x10f/0x120
> >  [<ffffffffa005d190>] ? scsi_next_command+0x3e/0x46 [scsi_mod]
> >  [<ffffffff812b665a>] ? _spin_lock+0x9/0xc
> >  [<ffffffff81247521>] ? netif_tx_lock+0x64/0x7e
> >  [<ffffffff81053d42>] ? sched_clock_cpu+0x10f/0x120
> >  [<ffffffff8124769b>] dev_watchdog+0xfe/0x15d
> >  [<ffffffff8124759d>] ? dev_watchdog+0x0/0x15d
> >  [<ffffffff81045212>] run_timer_softirq+0x19c/0x222
> >  [<ffffffff810570a2>] ? clockevents_program_event+0x73/0x7c
> >  [<ffffffff8104102e>] __do_softirq+0x7e/0x10c
> >  [<ffffffff8100dbcc>] call_softirq+0x1c/0x28
> >  [<ffffffff8100edd6>] do_softirq+0x4d/0xb0
> >  [<ffffffff81040c03>] irq_exit+0x4e/0x9d
> >  [<ffffffff8101ca3a>] smp_apic_timer_interrupt+0x8f/0xa8
> >  [<ffffffff8100d3d8>] apic_timer_interrupt+0x88/0x90
> >  <EOI>  [<ffffffff8102172a>] ? native_safe_halt+0x6/0x8
> >  [<ffffffff810132cf>] ? need_resched+0x1e/0x28
> >  [<ffffffff810133b4>] ? default_idle+0x2a/0x4c
> >  [<ffffffff81013504>] ? c1e_idle+0x120/0x127
> >  [<ffffffff812b963a>] ? atomic_notifier_call_chain+0x13/0x15
> >  [<ffffffff8100b279>] ? cpu_idle+0xb2/0x10b
> >  [<ffffffff812a49dd>] ? rest_init+0x61/0x63
> > 
> > ---[ end trace 9d3a40971e1bbe78 ]---

Were you doing anything in particular on the system whenever this
warning occurred?  Restarting the interface, perhaps?  Or
unplugging/replugging the network cable?  Restarting a router or switch?

Does it happen when the proprietary Nvidia driver isn't loaded?
