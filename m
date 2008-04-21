From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Mon, 21 Apr 2008 17:30:36 -0400
Message-ID: <480D077C.3090509@redhat.com>
References: <aiXVe-Yn-7@gated-at.bofh.it> <ajGfA-7rt-9@gated-at.bofh.it> <ajGfA-7rt-11@gated-at.bofh.it> <ajGfA-7rt-13@gated-at.bofh.it> <ajGfA-7rt-15@gated-at.bofh.it> <ajGfA-7rt-7@gated-at.bofh.it> <E1JnEcl-0000xc-D9@be1.7eggert.dyndns.org> <480CC3D8.3040700@hp.com> <alpine.LSU.0.999.0804212141050.4235@be1.lrz> <480CF2C0.9050208@hp.com> <alpine.LSU.0.999.0804212306330.15107@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Kok@vger.kernel.org,
	Auke <auke-jan.h.kok@intel.com>, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Anton Titov <a.titov@host.bg>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754909AbYDUVbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 17:31:34 -0400
In-Reply-To: <alpine.LSU.0.999.0804212306330.15107@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bodo Eggert wrote:
> On Mon, 21 Apr 2008, Rick Jones wrote:
>> Bodo Eggert wrote:
>>> On Mon, 21 Apr 2008, Rick Jones wrote:
> 
>>>> Be it kernel or user space, for consistent benchmark results it needs to
>>>> be
>>>> able to be turned-off without turning the code.  That leaves me in
>>>> agreement
>>>> with Stephen that if it must exist, the user space one would be
>>>> preferable.
>>>> It can be easily terminated with extreme prejudice.
>>>
>>> I agree that having a full-featured userspace balancer daemon with lots of
>>> intelligence will be theoretically better, but if you can have a simple
>>> daemon doing OK on many machines for less than the userspace daemon's
>>> kernel stack, why not?
>> Perhaps my judgement is too colored by benchmark(et)ing, and desires to have
>> repeatable results on things like neperf, but I very much like to know where
>> my interrupts are going and don't like them moving around. That is why I am
>> not particularly fond of either flavor of irq balancing.
>>
>> That being the case, whatever is out there aught to be able to be disabled on
>> a running system without having to roll bits or reboot.
> 
> Adding a "module" parameter to disable it should be cheap, isn't it?

Except the irq balancing is system-wide.  Adding per-device exemptions to an 
obsolete feature seems like the wrong way to go.

-- Chris
