From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 22:51:18 +1000
Message-ID: <20080821125118.GA8988@gondor.apana.org.au>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au> <20080821124936.GE4079@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60958 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754471AbYHUMvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:51:23 -0400
Content-Disposition: inline
In-Reply-To: <20080821124936.GE4079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 12:49:36PM +0000, Jarek Poplawski wrote:
>
> I don't think there could be such a problem, since nobody should look
> for such a destroyed qdisc: they look for their ancestors only.
> Anyway, I can't do this patch before evening, so I wait for
> suggestions or you could simply do it as you wish, no problem.

It's not about looking for the destroyed qdisc, it's about walking
the list and accidentally hitting the destroyed qdisc and wandering
into lalaland.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
