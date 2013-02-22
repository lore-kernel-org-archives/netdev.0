From: Ralf Friedl <Ralf.Friedl@online.de>
Subject: Re: Problem with Reaktek 8168
Date: Fri, 22 Feb 2013 15:55:19 +0100
Message-ID: <512786D7.6090003@online.de>
References: <5124B909.4080907@online.de> <20130220231122.GA22163@electric-eye.fr.zoreil.com> <51256EC7.90505@online.de> <20130221224543.GA11240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55332 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab3BVOzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 09:55:20 -0500
In-Reply-To: <20130221224543.GA11240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> I have not noticed 8168f specific problems as of late. It could be worth
> giving stock 3.8 a try though: its load of changes includes some post
> 3.4.x branch 8168f bits.
>   
Thank you very much.
I just installed the OpenSuse kernel 3.8.0-2.1 and transferred my 
collection of Linux install images, about 145G, to and from another 
computer, without a single problem.

So whatever was changed fixed the issue.

I have one warning in the syslog, but I hope it is not serious.
WARNING: at net/sched/sch_generic.c:254 dev_watchdog+0x239/0x250()
NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Call Trace:
 <IRQ>  [<ffffffff810355c9>] ? warn_slowpath_common+0x79/0xc0
 [<ffffffff810356c5>] ? warn_slowpath_fmt+0x45/0x50
 [<ffffffff813096c9>] ? dev_watchdog+0x239/0x250
 [<ffffffff81309490>] ? pfifo_fast_dequeue+0xd0/0xd0
 [<ffffffff810415ba>] ? call_timer_fn.isra.32+0x2a/0x90
 [<ffffffff8104177e>] ? run_timer_softirq+0x15e/0x1f0
 [<ffffffff811ce4c9>] ? timerqueue_add+0x59/0xa0
 [<ffffffff8103c314>] ? __do_softirq+0xa4/0x150
 [<ffffffff810733df>] ? clockevents_program_event+0x6f/0x110
 [<ffffffff8138bf4c>] ? call_softirq+0x1c/0x30
 [<ffffffff8100464d>] ? do_softirq+0x4d/0x80
 [<ffffffff8103c4e6>] ? irq_exit+0x86/0xa0
 [<ffffffff810221e8>] ? smp_apic_timer_interrupt+0x68/0xa0
 [<ffffffff8138b94a>] ? apic_timer_interrupt+0x6a/0x70
 <EOI>  [<ffffffff81042074>] ? get_next_timer_interrupt+0x1d4/0x270
 [<ffffffff812c2a71>] ? cpuidle_wrap_enter+0x41/0x80
 [<ffffffff812c2a6d>] ? cpuidle_wrap_enter+0x3d/0x80
 [<ffffffff812c2838>] ? cpuidle_idle_call+0x78/0x100
 [<ffffffff8100b22f>] ? cpu_idle+0x5f/0xd0


Ralf
