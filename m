From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Mon, 21 Jul 2008 16:57:47 +0400
Message-ID: <20080721125747.GA3056@2ka.mipt.ru>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI> <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu> <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com> <20080721100627.GA5953@2ka.mipt.ru> <20080721105051.GA5830@elte.hu> <20080721112515.GA4777@2ka.mipt.ru> <20080721115555.GA24176@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:50657 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847AbYGUM6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 08:58:09 -0400
Content-Disposition: inline
In-Reply-To: <20080721115555.GA24176@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 01:55:55PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > > I could try run tests with netconsole deactivated, if you think 
> > > that's a worthwile line of probing this problem. (although that 
> > > would make me do blind tests in essence - having kernel log output 
> > > is really essential.)
> > 
> > Let's try this way first. If system will continue to crash, we will 
> > add some debug options in various pathes. Existing reports do not 
> > contain enough information unfortunately, so we will not lose too 
> > much.
> 
> ok. I've turned off netconsole - 8 successful bootups in a row so far. 
> The box is a slow booter/builder with an 8 kernels/hour test throughput, 
> so if everything goes fine we should have meaningful results in about 10 
> hours.
> 
> ( there are other, faster testboxes in -tip testing with 33 kernels/hour 
>   build+boot throughput where we'd have to wait only 2 hours - but as 
>   per Murphy's law they dont trigger this bug ;-)

Since 2.6.25 there was only single change in netpoll.c:
f5184d267c1aedb9b7a8cc44e08ff6b8d382c3b5
Which looks innocent.

Is your driver e1000 or e1000e? Can you check different one?

-- 
	Evgeniy Polyakov
