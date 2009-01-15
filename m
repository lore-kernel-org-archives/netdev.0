From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.28: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed
 out
Date: Wed, 14 Jan 2009 21:36:18 -0800
Message-ID: <20090114213618.a610d647.akpm@linux-foundation.org>
References: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Alan Piszcz <ap@solarrain.com>,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44177 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbZAOFg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:36:28 -0500
In-Reply-To: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc's added)

On Tue, 13 Jan 2009 16:19:22 -0500 (EST) Justin Piszcz <jpiszcz@lucidpixels.com> wrote:

> Most likely disabling this (onboard-nic) and using Intel PCI-Express 1 
> Gbps card but FYI:
> 
> [505628.695393] ------------[ cut here ]------------
> [505628.695398] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x22e/0x240()
> [505628.695400] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
> [505628.695403] Pid: 0, comm: swapper Not tainted 2.6.28 #1
> [505628.695405] Call Trace:
> [505628.695407]  <IRQ>  [<ffffffff8024f628>] warn_slowpath+0xc8/0x110
> [505628.695416]  [<ffffffff805b9310>] ip_finish_output+0x0/0x2b0
> [505628.695419]  [<ffffffff8059e3e4>] eth_header+0x34/0xd0
> [505628.695423]  [<ffffffff804078c9>] __next_cpu+0x19/0x30
> [505628.695427]  [<ffffffff802472dc>] find_busiest_group+0x1dc/0x970
> [505628.695432]  [<ffffffff802308b9>] read_tsc+0x9/0x20
> [505628.695436]  [<ffffffff802599c4>] lock_timer_base+0x34/0x70
> [505628.695440]  [<ffffffff8026aa98>] getnstimeofday+0x48/0xc0
> [505628.695443]  [<ffffffff8040d601>] strlcpy+0x41/0x50
> [505628.695447]  [<ffffffff8059e9fe>] dev_watchdog+0x22e/0x240
> [505628.695449]  [<ffffffff802308b9>] read_tsc+0x9/0x20
> [505628.695453]  [<ffffffff8059e7d0>] dev_watchdog+0x0/0x240
> [505628.695456]  [<ffffffff802594be>] run_timer_softirq+0x12e/0x200
> [505628.695460]  [<ffffffff80238c35>] lapic_next_event+0x15/0x20
> [505628.695463]  [<ffffffff80254e13>] __do_softirq+0x93/0x160
> [505628.695467]  [<ffffffff802684c2>] hrtimer_interrupt+0x152/0x1c0
> [505628.695471]  [<ffffffff8022aabc>] call_softirq+0x1c/0x30
> [505628.695474]  [<ffffffff8022c455>] do_softirq+0x35/0x70
> [505628.695477]  [<ffffffff802394f6>] smp_apic_timer_interrupt+0x86/0xd0
> [505628.695480]  [<ffffffff8022a50b>] apic_timer_interrupt+0x6b/0x70
> [505628.695482]  <EOI>  [<ffffffff805f0320>] unix_poll+0x0/0xb0
> [505628.695489]  [<ffffffff8023147c>] mwait_idle+0x3c/0x50
> [505628.695493]  [<ffffffff80228a1c>] cpu_idle+0x5c/0x90
> [505628.695495] ---[ end trace eddb8da7fddd6198 ]---
> [505628.700048] r8169: eth0: link up
> 
> I believe this occured when trying to burn a DVD via Nero over a 1gbps 
> connection.

Is this new behaviour?  Was 2.6.27 OK?

Thanks.
