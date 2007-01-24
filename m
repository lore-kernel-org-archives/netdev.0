From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6] RAW: Add checksum default defines for MH.
Date: Wed, 24 Jan 2007 17:56:23 +1100
Message-ID: <E1H9c3T-0005HA-00@gondolin.me.apana.org.au>
References: <20070123.221918.35467190.davem@davemloft.net>
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	takamiya@po.ntts.co.jp, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2035 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933168AbXAXG4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:56:46 -0500
In-Reply-To: <20070123.221918.35467190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> Did a complete agreement occur that this patch is ok?

My only concern is that we're putting an arbitrary list of
protocols in the generic raw.c.  What's the justification
for including these protocols in particular but not others?

Is there any reason why the application can't just use the
existing IPV6_CHECKSUM socket option to set the same fields?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
