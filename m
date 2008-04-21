From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Mon, 21 Apr 2008 09:42:00 -0700
Message-ID: <480CC3D8.3040700@hp.com>
References: <aiXVe-Yn-7@gated-at.bofh.it> <ajGfA-7rt-9@gated-at.bofh.it>	<ajGfA-7rt-11@gated-at.bofh.it> <ajGfA-7rt-13@gated-at.bofh.it>	<ajGfA-7rt-15@gated-at.bofh.it> <ajGfA-7rt-7@gated-at.bofh.it> <E1JnEcl-0000xc-D9@be1.7eggert.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kok@vger.kernel.org, Auke <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Anton Titov <a.titov@host.bg>, Chris Snook <csnook@redhat.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: 7eggert@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:31131 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbYDUQmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 12:42:07 -0400
In-Reply-To: <E1JnEcl-0000xc-D9@be1.7eggert.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bodo Eggert wrote:
> Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> 
> 
>>[X86] IRQBALANCE: Mark as BROKEN and disable by default
>>
>>The IRQBALANCE option causes interrupts to bounce all around on SMP systems
>>quickly burying the CPU in migration cost and cache misses. Mainly affected
>>are network interrupts and this results in one CPU pegged in softirqd
>>completely.
> 
> 
> If this is the problem, maybe it would help to only balance the IRQs each
> e.g. ten seconds? Unfortunately I have no SMP system to try it out.

Be it kernel or user space, for consistent benchmark results it needs to 
be able to be turned-off without turning the code.  That leaves me in 
agreement with Stephen that if it must exist, the user space one would 
be preferable.  It can be easily terminated with extreme prejudice.

rick jones
