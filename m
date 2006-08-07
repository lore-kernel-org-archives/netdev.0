From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 16:42:33 +1000
Message-ID: <20060807064233.GA4993@gondor.apana.org.au>
References: <20060807060155.GA6487@2ka.mipt.ru> <E1G9ybt-0001GT-00@gondolin.me.apana.org.au> <20060807063636.GB11483@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40970 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751109AbWHGGml
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 02:42:41 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060807063636.GB11483@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 10:36:36AM +0400, Evgeniy Polyakov wrote:
> 
> Well, theirs comments in code say, that maximum allowed frame size is
> 0x3f00, so there is a little place at the end to put there a pointer,
> so I allocate size + sizeof(void *).
> If they actually can eat all 16k, then we need a pointer somewhere in
> the skb for shared_info, since 16k + sizeof(void *) will be aligned to
> 32k.

It would be good to get a definitive statement from them before we go
down this track.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
