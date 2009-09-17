From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [crash] kernel BUG at net/core/pktgen.c:3503!
Date: Thu, 17 Sep 2009 19:44:48 +0200
Message-ID: <20090917174448.GA9548@elte.hu>
References: <20090911.202543.52533792.davem@davemloft.net> <20090915183647.GA11628@elte.hu> <20090915185112.GA17587@lenovo> <20090917.102923.174779685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gorcunov@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:43418 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757643AbZIQRow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 13:44:52 -0400
Content-Disposition: inline
In-Reply-To: <20090917.102923.174779685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Tue, 15 Sep 2009 22:51:12 +0400
> 
> > [Ingo Molnar - Tue, Sep 15, 2009 at 08:36:47PM +0200]
> > | 
> > | not sure which merge caused this, but i got this boot crash with latest 
> > | -git:
> > | 
> > | calling  flow_cache_init+0x0/0x1b9 @ 1
> > | initcall flow_cache_init+0x0/0x1b9 returned 0 after 64 usecs
> > | calling  pg_init+0x0/0x37c @ 1
> > | pktgen 2.72: Packet Generator for packet performance testing.
> > | ------------[ cut here ]------------
> > | kernel BUG at net/core/pktgen.c:3503!
> > | invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > | last sysfs file: 
> > | 
> > 
> > Hi Ingo,
> > 
> > just curious, will the following patch fix the problem?
> > I've been fixing problem with familiar symthoms on
> > system with custome virtual cpu implementation so
> > it may not help in mainline but anyway :)
> 
> Ingo, does Cyrill's patch help?

For now i've turned pktgen off in my tests. Will check it again once 
things have calmed down somewhat.

Also, i just tried to reproduce the pktgen crash with latest -git and 
the config i sent - no luck, so i cannot test Cyrill's patch either.

Btw., we are seeing some other preempt count and task related 
weirdnesses as well in other code, maybe it's related. No good pattern 
yet to act upon.

Anyway - please disregard this bugreport until i've investigated it 
closer.

	Ingo
