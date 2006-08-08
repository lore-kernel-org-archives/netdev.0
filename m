From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Tue, 8 Aug 2006 15:41:15 +1000
Message-ID: <20060808054115.GA14544@gondor.apana.org.au>
References: <20060806.232339.30184217.davem@davemloft.net> <E1G9zMP-0001MO-00@gondolin.me.apana.org.au> <20060807072423.GA2078@2ka.mipt.ru> <20060807072816.GA5404@gondor.apana.org.au> <20060807073103.GA11283@2ka.mipt.ru> <20060807073919.GA5582@gondor.apana.org.au> <4807377b0608071709j26da1092la20f1589c7b90df7@mail.gmail.com> <20060808052408.GA7279@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	chris.leech@gmail.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:26637 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932080AbWHHFlc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 01:41:32 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060808052408.GA7279@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 09:24:08AM +0400, Evgeniy Polyakov wrote:
> 
> So there is no place at the end of skb for additional pointer.
> And new question arises - until what Jesse suggested is implemented in
> some way, do we need to store a pointer to shared info inside skb and
> allocate it from cache in case it does no fit into aligned buffer (in
> case of e1000 it happens all the time exept 1500 MTU)?
> David, Herbert?

I'm not sure whether this is really worth it.  After all, the only
order of allocation that's really likely to succeed is 0.  So going
from order 3 to order 2 probably doesn't make that big a difference.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
