From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 10:41:47 +1100
Message-ID: <20081217234147.GA28797@gondor.apana.org.au>
References: <20081217221637.GA27811@gondor.apana.org.au> <20081217.151713.90960645.davem@davemloft.net> <20081217232553.GA28582@gondor.apana.org.au> <20081217.153442.166884508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39093 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751762AbYLQXmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:42:07 -0500
Content-Disposition: inline
In-Reply-To: <20081217.153442.166884508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 03:34:42PM -0800, David Miller wrote:
>
> > 2) Even if we did this would be broken either way because just
> > where do you put the urgent pointer if your packet is > 64K and
> > the urgent pointer lies in the packet but beyond 64K to the start?
> 
> You would need to chop up the packet to allow proper specification of
> the URG pointer.

Right, and it'd be just as easy to chop up the packet so that we
can set the urgent pointer to 0xffff :)

> I agree that prompt signalling of the URG condition is desirable.
> 
> None of the RFCs seem to give any real guidance in this area, and that
> explains the plethora of ways we see various stacks handling this
> situation.
> 
> I'll think about your patch some more, but no promises.

This is definitely something that we don't want to rush into.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
