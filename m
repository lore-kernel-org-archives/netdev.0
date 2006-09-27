From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] neighbour.c, pneigh_get_next() skips published entry
Date: Wed, 27 Sep 2006 21:12:57 +1000
Message-ID: <E1GSXLV-0000ud-00@gondolin.me.apana.org.au>
References: <4518C1C3.10004@snapgear.com>
Cc: davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org,
	jari.takkala@q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29454 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965563AbWI0LNZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 07:13:25 -0400
To: philipc@snapgear.com (Philip Craig)
In-Reply-To: <4518C1C3.10004@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig <philipc@snapgear.com> wrote:
> 
> It is faster to reproduce with a smaller block size.
> I haven't looked in detail to find the cause, but I did notice that
> neigh_seq_start() does a pos_minus_one adjustment, and neigh_seq_next()
> does not.

Yeah I can reproduce this now.  I think you actually sent me
the instructions before but I didn't get around to testing it.
Sorry about that.

I'll look into this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
