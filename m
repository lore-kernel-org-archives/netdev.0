From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Mon, 21 Aug 2006 13:02:01 +0200
Message-ID: <20060821110201.GA3674@ff.dom.local>
References: <20060817093615.GA25553@ms2.inr.ac.ru> <20060821081642.GA2637@ff.dom.local> <20060821.011703.78716718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:59297 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751855AbWHUK7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 06:59:04 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060821.011703.78716718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21-08-2006 10:17, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Mon, 21 Aug 2006 10:16:43 +0200
...
>> But I hope the real reason for this patch isn't exactly like that.
>> Could fib_release_info() be interrupted by BH really?
> 
> Absolutely, yes it can.  What makes you think it can't?
> 
> All of the call sites I have checked cause it to run with
> BH's enabled, and that allows ip_fib_check_default() to
> potentially run.  All we need is one such case to cause
> the deadlock.
> 
> I was skeptical of this case too, until I checked how
> fib_release_info() was called.

I overlooked this - so I've to sharpen my sight and look at it 
again - now knowing it's there.
Thanks for your response. I didn't expect it so fast and right 
from the top!

Jarek P.
