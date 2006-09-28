From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] myri10ge Large Receive Offload
Date: Thu, 28 Sep 2006 10:53:42 +1000
Message-ID: <E1GSk9m-0002NX-00@gondolin.me.apana.org.au>
References: <451B0541.1030208@myri.com>
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22790 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1031305AbWI1AyI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 20:54:08 -0400
To: brice@myri.com (Brice Goglin)
In-Reply-To: <451B0541.1030208@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin <brice@myri.com> wrote:
> This is a complete rework of the myri10ge receive path. The first
> patch converts skb allocation to use physical pages. The second one
> adds a software implementation of Large Receive Offload. The third
> one updates the driver version to 1.1.0.

If this LRO is completely in software it might be time to consider
something more generic since this would be the second software LRO
implementation (the other being s2io).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
