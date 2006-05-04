From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP]: Fix sock_orphan dead lock
Date: Wed, 03 May 2006 23:32:23 -0700 (PDT)
Message-ID: <20060503.233223.24747225.davem@davemloft.net>
References: <20060427123404.GA20489@gondor.apana.org.au>
	<20060429111507.GA3077@gondor.apana.org.au>
	<20060429131320.GA4145@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, arjan@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9169
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751408AbWEDGdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:33:12 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060429131320.GA4145@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 29 Apr 2006 23:13:20 +1000

> On Sat, Apr 29, 2006 at 09:15:07PM +1000, herbert wrote:
> > 
> > Unfortunately this is only true for TCP.  All of the connectionless
> > protocols use the callback lock without the socket lock so it does
> > still serve a purpose.
> > 
> > I'd be happy to see your patch included.
> 
> I've just changed my mind :) Instead of disabling BH on the read_lock
> callers, we can instead move sock_orphan outside bh_lock_sock.
> 
> [TCP]: Fix sock_orphan dead lock

Ok, it took me a while to review this one as verifying such
a set of changes is always tricky, but looks good!

Applied, thanks a lot.
