From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] ip: skip IP checksum for skbs with CHECKSUM_UNNECESSARY set
Date: Sat, 23 Aug 2008 15:15:17 +1000
Message-ID: <E1KWlT3-0001HJ-00@gondolin.me.apana.org.au>
References: <20080822.173625.182460185.davem@davemloft.net>
Cc: shemminger@vyatta.com, opurdila@ixiacom.com, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32906 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751609AbYHWFPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 01:15:22 -0400
In-Reply-To: <20080822.173625.182460185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> I don't think they want this for performance, they want to not have to
> compute the IP header checksum in their HW LRO implementation, which
> is just as silly :-)

I sure hope they're not planning on leaving out the IP header
checksum verification too :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
