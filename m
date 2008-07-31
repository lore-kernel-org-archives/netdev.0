From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 03:43:38 -0700 (PDT)
Message-ID: <20080731.034338.146687281.davem@davemloft.net>
References: <20080730.145727.07367670.davem@davemloft.net>
	<20080730151316.a4d76fe9.akpm@linux-foundation.org>
	<1217500776.3454.136.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757332AbYGaKni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:43:38 -0400
In-Reply-To: <1217500776.3454.136.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 31 Jul 2008 11:39:36 +0100

> We need to be moving towards a situation where people don't _need_ to
> patch the hell out of their kernels to make Linux viable for embedded
> devices. I'm not prepared just assume that 'they will always do so', and
> I'm disappointed to hear Andrew say such a thing. 

It's simple economics, really.

Until they see value in upstream submission, it's always going
to be %100 invested in getting the current product out the door
or the current fire put out.

The odd I2C device hack of the day the do to one revision of their
product is likely never to be submitted upstream.  And these
embedded folks have hundreds of things on that level that they
sort out for each product, and often very little of it is reusable
in the next product.

They don't see the payback for upstreaming this stuff, and for
a lot of cases neither do I.
