From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Sat, 19 Apr 2008 17:05:06 +0200
Message-ID: <E1JnEcl-0000xc-D9__34428.1591861092$1208627224$gmane$org@be1.7eggert.dyndns.org>
References: <aiXVe-Yn-7@gated-at.bofh.it> <ajGfA-7rt-9@gated-at.bofh.it> <ajGfA-7rt-11@gated-at.bofh.it> <ajGfA-7rt-13@gated-at.bofh.it> <ajGfA-7rt-15@gated-at.bofh.it> <ajGfA-7rt-7@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
To: Kok@vger.kernel.org, Auke <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:53028 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbYDSPFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 11:05:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> [X86] IRQBALANCE: Mark as BROKEN and disable by default
> 
> The IRQBALANCE option causes interrupts to bounce all around on SMP systems
> quickly burying the CPU in migration cost and cache misses. Mainly affected
> are network interrupts and this results in one CPU pegged in softirqd
> completely.

If this is the problem, maybe it would help to only balance the IRQs each
e.g. ten seconds? Unfortunately I have no SMP system to try it out.


