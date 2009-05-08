From: David Miller <davem@davemloft.net>
Subject: Re: via velocity trivial patch
Date: Fri, 08 May 2009 12:40:41 -0700 (PDT)
Message-ID: <20090508.124041.17500179.davem@davemloft.net>
References: <4A01FBF6.1090001@podgorny.cz>
	<20090507.150213.192379856.davem@davemloft.net>
	<4A04184E.5040507@podgorny.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: radek@podgorny.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754807AbZEHTkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 15:40:45 -0400
In-Reply-To: <4A04184E.5040507@podgorny.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radek Podgorny <radek@podgorny.cz>
Date: Fri, 08 May 2009 13:32:30 +0200

> The "some garbage" are just my words for what Jeff Garzik called "also
> bail if 0xffffffff (hardware fault / hardware unplugged)" in
> http://lkml.indiana.edu/hypermail/linux/kernel/0406.0/0500.html in 2004.
> Should I change that?
> 
> Anyway, I've verified this is really happening on my hardware when
> multiple via velocity devices share the same interrupt. The one the
> interrupt is for reads the correct ISR value, the others sometimes read
> 0 and sometimes 0xffffffff. I'm not educated enough to tell why.
> 
> Reasons to include the fix:
> 1) Someone smarter than me suggested it (Jeff Garzik).
> 2) Fixed my problem.
> 3) Does not introduce a new problem.
> 
> So I'm attaching the patch again. Now with the proper sign-off.

I don't think we should include this until we know why your
card is showing this value in the status register.

Since I assume you aren't unplugging the device showing this
behavior, the only possible remaining reason is "hardware fault"
and we need to understand that better before we start working
around it.

I consider it a good bet that Jeff has no idea why the chip is
doing this either. :-)

