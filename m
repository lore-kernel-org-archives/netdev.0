From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
	encapsulation mode
Date: Thu, 18 Dec 2008 14:57:58 +1100
Message-ID: <20081218035758.GA31610@gondor.apana.org.au>
References: <1228396731.1643.57.camel@martin> <E1LD9rC-0007y7-KY@gondolin.me.apana.org.au> <20081217.194942.01082060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52391 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750789AbYLRD6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:58:05 -0500
Content-Disposition: inline
In-Reply-To: <20081217.194942.01082060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 07:49:42PM -0800, David Miller wrote:
>
> IKEv2 daemon needs to be agnostic about this situation.  So we have to
> accept everything, regardless of configured encapsulation type.
> 
> At least that is my impression after reading the MOBIKE documents.

The NAT-T encapsulation is an SA-specific attribute, so it's
decided when the SA is negotiated.  There is a mechanism for
detecting changes in the peer's address and updating the SA.

However, I can't see why you would ever need to switch between
having UDP encapsulation and not having it, without negotiating
it with the peer.  That is, the UDP encapsulation works whether
you have NAT or not.

Do you have a specific quote that I can check against?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
