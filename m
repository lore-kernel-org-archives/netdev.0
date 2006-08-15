From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: XFRM_MSG_NEWAE
Date: Tue, 15 Aug 2006 18:07:31 +1000
Message-ID: <E1GCtxT-0000up-00@gondolin.me.apana.org.au>
References: <20060815.002852.35359129.davem@davemloft.net>
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60940 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965287AbWHOIHs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 04:07:48 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060815.002852.35359129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> I think we need a way to tone this down, so that if there are no truly
> interested parties we don't do the km->notify work at all.

Actually, we do turn it off if nobody is listening, through
xfrm_aevent_is_on().

> Also it would be nice to add xfrm mon support to print out these
> messages properly if you haven't coded that up already :-)

Yes that would be good :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
