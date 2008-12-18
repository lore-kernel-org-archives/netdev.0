From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
	encapsulation mode
Date: Thu, 18 Dec 2008 15:14:19 +1100
Message-ID: <20081218041419.GA11722@gondor.apana.org.au>
References: <1228396731.1643.57.camel@martin> <E1LD9rC-0007y7-KY@gondolin.me.apana.org.au> <20081217.194942.01082060.davem@davemloft.net> <20081218035758.GA31610@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36192 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751339AbYLREO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 23:14:26 -0500
Content-Disposition: inline
In-Reply-To: <20081218035758.GA31610@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 02:57:58PM +1100, Herbert Xu wrote:
>
> However, I can't see why you would ever need to switch between
> having UDP encapsulation and not having it, without negotiating
> it with the peer.  That is, the UDP encapsulation works whether
> you have NAT or not.
> 
> Do you have a specific quote that I can check against?

A quick google failed to reveal any specific requirements apart
from the need to move in and out of NAT environments.

That isn't actually an issue because when your addresses change
you have to renegotiate with the other side to ensure that this
isn't some kind of an attack.  Afterwards you have to recreate
the SAs at which point you can easily set the encapsulation to
whatever it should be.

The only time when you need this patch is if the other side
unilaterally switched from NAT-T to no NAT-T, or vice versa,
which does not sound like a sane thing to do.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
