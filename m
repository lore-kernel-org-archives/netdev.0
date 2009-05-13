From: Andi Kleen <andi@firstfloor.org>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 10:34:57 +0200
Message-ID: <874ovpmmdq.fsf@basil.nowhere.org>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>
	<20090508.234815.127227651.davem@davemloft.net>
	<4A086DB2.8040703@nortel.com>
	<20090511.162436.193717082.davem@davemloft.net>
	<4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>
	<4A09933B.8010606@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36974 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbZEMIfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 04:35:02 -0400
In-Reply-To: <4A09933B.8010606@nortel.com> (Chris Friesen's message of "Tue, 12 May 2009 09:18:19 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Chris Friesen" <cfriesen@nortel.com> writes:
>
> One of the reasons I brought up this issue is that there is a lot of
> documentation out there that says "softirqs will be processed on return
> from a syscall".  The fact that it actually depends on the scheduler
> parameters of the task issuing the syscall isn't ever mentioned.

It's not mentioned because it is not currently.

However some network TCP RX processing can happen in process context,
which gives you most of the benefit anyways.

> In fact, "Documentation/DocBook/kernel-hacking.tmpl" in the kernel
> source still has the following:
>
>     Whenever a system call is about to return to userspace, or a
>     hardware interrupt handler exits, any 'software interrupts'
>     which are marked pending (usually by hardware interrupts) are
>     run (<filename>kernel/softirq.c</filename>).
>
> If anyone is looking at changing this code, it might be good to ensure
> that at least the kernel docs are updated.

So far the code is not changed in mainline. There have been some
proposals only.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
