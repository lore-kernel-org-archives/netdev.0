From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: hard_start_xmit  conext
Date: Wed, 16 Aug 2006 13:08:36 +1000
Message-ID: <E1GDBlk-0006O1-00@gondolin.me.apana.org.au>
References: <BAY119-F167D4D4A8CA125150C0A60D44F0@phx.gbl>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:7429 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750868AbWHPDIj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 23:08:39 -0400
To: kkiran78@hotmail.com (kiran kandi)
In-Reply-To: <BAY119-F167D4D4A8CA125150C0A60D44F0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kiran kandi <kkiran78@hotmail.com> wrote:
> 
> In what context hard_start_xmit  function is called. Is it called in soft 
> irq or a  processes context.

softirq

> Also can you call kfree_skb in  soft irq context.

Yes.  Don't do it in hard irq context though.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
