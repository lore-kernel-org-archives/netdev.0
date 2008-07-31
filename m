From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:49:31 +0100
Message-ID: <1217501371.3454.148.camel@pmac.infradead.org>
References: <20080730.145727.07367670.davem@davemloft.net>
	 <20080730151316.a4d76fe9.akpm@linux-foundation.org>
	 <1217500776.3454.136.camel@pmac.infradead.org>
	 <20080731.034338.146687281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50689 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbYGaKuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:50:22 -0400
In-Reply-To: <20080731.034338.146687281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-31 at 03:43 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Thu, 31 Jul 2008 11:39:36 +0100
> 
> > We need to be moving towards a situation where people don't _need_ to
> > patch the hell out of their kernels to make Linux viable for embedded
> > devices. I'm not prepared just assume that 'they will always do so', and
> > I'm disappointed to hear Andrew say such a thing. 
> 
> It's simple economics, really.
> 
> Until they see value in upstream submission, it's always going
> to be %100 invested in getting the current product out the door
> or the current fire put out.

They are starting to see value in upstream submission. Even when I was
working for my previous employer, when we first started doing embedded
Linux contracts, it was sometimes a fight to be allowed the time to
merge stuff upstream.

But they had learned for themselves, over time, that it actually helps
them in the long run if they do that. Because when they come to do a
product update, or a new product similar to and old one, it means they
don't have to start again from scratch.

That seems to be something that everyone seems to need to learn for
themselves. We can tell them about it until we're blue in the face (and
I was in Japan and Korea doing just that to CELF folks earlier this
year), but they still don't really believe it until it's bitten _them_.

> The odd I2C device hack of the day the do to one revision of their
> product is likely never to be submitted upstream.  And these
> embedded folks have hundreds of things on that level that they
> sort out for each product, and often very little of it is reusable
> in the next product.

Even that kind of stuff is getting nicer. The device-tree magic we have
for PowerPC boards means that you often don't need any code changes at
all when you bring up a new board -- you just have a device-tree which
describes the hardware. And that covers i2c devices too.

> They don't see the payback for upstreaming this stuff, and for
> a lot of cases neither do I.

They're learning. And we need to too :)

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



