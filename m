From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 17:39:19 +1000
Message-ID: <20060807073919.GA5582@gondor.apana.org.au>
References: <20060806.232339.30184217.davem@davemloft.net> <E1G9zMP-0001MO-00@gondolin.me.apana.org.au> <20060807072423.GA2078@2ka.mipt.ru> <20060807072816.GA5404@gondor.apana.org.au> <20060807073103.GA11283@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	chris.leech@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:30988 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751117AbWHGHjc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 03:39:32 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060807073103.GA11283@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 11:31:03AM +0400, Evgeniy Polyakov wrote:
> 
> Only if they form contiguous region?
> Jesse, is it possible for every e1000 chip to split frame into several
> page-sized chunks i.e. create some kind of receiving scatter-gather?

Actually, it was Chris Leech who raised this possibility:

: Yes, e1000 devices will spill over and use multiple buffers for a
: single frame.  We've been trying to find a good way to use multiple
: buffers to take care of these allocation problems.  The structure of
: the sk_buff does not make it easy.  Or should I say that it's the
: limitation that drivers are not allowed to chain together multiple
: sk_buffs to represent a single frame that does not make it easy.

Perhaps he can enlighten us.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
