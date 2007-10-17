From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9174] New: linux-2.6.23-git11 kernel panic
Date: Wed, 17 Oct 2007 13:01:31 -0700
Message-ID: <20071017130131.365f9fb6.akpm@linux-foundation.org>
References: <bug-9174-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: plamen.petrov@tk.ru.acad.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38171 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759382AbXJQUCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 16:02:35 -0400
In-Reply-To: <bug-9174-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Oct 2007 07:36:16 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9174
> 
>            Summary: linux-2.6.23-git11 kernel panic
>            Product: Other
>            Version: 2.5
>      KernelVersion: 2.6.23-git11
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: other_other@kernel-bugs.osdl.org
>         ReportedBy: plamen.petrov@tk.ru.acad.bg
> 
> 
> Most recent kernel where this bug did not occur: 2.6.23
> Distribution:Slackware 12
> Hardware Environment: AMD Duron 900, 512 MB RAM, 3x Realtek 8139 based NICs
> Software Environment: 
> Problem Description:
>  Machine booted OK, I logged in, started "mc", and got the kernel panic;
> As you can see from the kernel panic, the process where it happened is
> FahCore_81.exe, which is the linux client of the Folding @ HOME project;
> other programs started before I logged in the machine, too.
> 

It's better to report recently-occurring bugs via email, please - bugzilla
is more for long-term things.  But still - thanks for reporting the bug!

Let's keep this to email so please follow up via emailed reply-to-all.

> EIP is at packet_rcv_0x1a2/0x360
> eax: 00000000	ebx: c2fd1190	ecx: c2fd11a4	edx: c2fd11a4
> esi: c26ee800	edi: c2c90200	ebp: c343f434	esp: c2dd5ed4
> ds: 007b	es: 007b	fs: 0000	gs: 0000	ss: 0068
> Process FahCore_81.exe (pid: 1290, ti=c2dd4000 task=c2dd0530 task.ti=c2dd4000)
> Stack: 000000c0 00000020 0008ab40 c05604c0 00000068 00000068 c2fd11a0 c2fd11a4
> 	   00000068 c2fd1180 c0563500 c2fd10c0 0000dd86 c056b6e8 c03477d4 c26ee800
> 	   00000040 c1a9a370 dd86a000 c2c90358 c26ee800 c26ee800 00000000 c05edd3c
> Call Trace:
>  [<c03477d4>] netif_recieve_skb+0x174/0x370
>  [<c0349e1c>] process_backlog+0x5c/oxb0
>  [<c0349ab3>] net_rx_action+0x43/0xf0
>  [<c011ef92>] __do_softirq+0x42/0x90
>  [<c011f007>] do_softirq_0x27/0x30
>  [<c011f2da>] irq_exit+0x5a/0x60
>  [<c0104eba>] do_IRQ+0x4a/0x80
>  [<c0456b18>] schedule+0x148/0x270
>  [<c010321f>] common_interrupt+0x23/0x28
>  =======================
> Code: 02 0f b6 43 65 83 e0 07 88 42 0a f6 87 78 01 00 00 04 0f 85 84 01 00 00 8b
>  46 44 8b 4c 24 1c 89 41 04 8b 43 14 8b 80 b8 00 00 00 <8b> 48 04 31 c0 85 c9 74
>  0b 8b 54 24 1c 89 d8 83 c2 0c ff d1 8b
> EIP: [<c0422782>] packet_rcv+0x1a2/0x360 SS:ESP 0068:c2dd5ed4
> Kernel panic - not syncing: Fatal exception in interrupt
> 

config is in the bugzilla report.  Seems that 8139too is the NIC.
