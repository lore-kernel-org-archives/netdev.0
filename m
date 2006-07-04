From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input
Date: Tue, 4 Jul 2006 12:45:27 +1000
Message-ID: <20060704024527.GA31361@gondor.apana.org.au>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter> <20060701033939.GC29803@gondor.apana.org.au> <20060703.194406.23013279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:14867 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751378AbWGDCqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 22:46:39 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060703.194406.23013279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2006 at 07:44:06PM -0700, David Miller wrote:
>
> > I think we need some new ethtool helper functions that sets/clears both
> > TSO/TSO6.
> 
> Do you really want to semantically seperate TSO and TSO6?
> 
> I would think that real users who want to disable TSO, wish
> to do so unilaterally.

That's what I meant.  I meant ethtool helper functions that
clear and set both TSO/TSO6 flags at the same time.

Alternatively, we can add a new features bit which gives the inherent
features of a device.  That can then be used to derive the actual
features in use.  That way we won't need to invent a new ethtool
helper function for this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
