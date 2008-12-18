From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
	encapsulation mode
Date: Thu, 18 Dec 2008 15:21:42 +1100
Message-ID: <20081218042142.GA15884@gondor.apana.org.au>
References: <20081217.194942.01082060.davem@davemloft.net> <20081218035758.GA31610@gondor.apana.org.au> <20081218041419.GA11722@gondor.apana.org.au> <20081217.201755.11960524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51471 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751210AbYLREVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 23:21:48 -0500
Content-Disposition: inline
In-Reply-To: <20081217.201755.11960524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 08:17:55PM -0800, David Miller wrote:
>
> My interpretation of the situation is that when you change (address or
> NAT-T) you still have to perform the renegotiation over the old SA.
> 
> Or something like that.

Do you have a pointer to that?

For each connection you have a pair of SAs, they're keyed by

	(dst, spi, proto)

So if one party's address changes then you immediately lose one
direction, which means the SAs are now inoperable as a bi-directional
channel.

In any case, AFAIK negotiations are conducted outside of SAs, on
port 500 or 4500, so this shouldn't matter.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
