From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input
Date: Tue, 4 Jul 2006 14:04:14 +1000
Message-ID: <20060704040414.GA31980@gondor.apana.org.au>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter> <20060701033939.GC29803@gondor.apana.org.au> <20060703.194406.23013279.davem@davemloft.net> <20060704024527.GA31361@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53764 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751292AbWGDEEZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 00:04:25 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060704024527.GA31361@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2006 at 12:45:27PM +1000, herbert wrote:
> 
> That's what I meant.  I meant ethtool helper functions that
> clear and set both TSO/TSO6 flags at the same time.

I think I was a bit ambiguous here.  To expand on my argument, what
I'm saying is that we can't just change the existing ethtool helper
functions to set TSO6 since that'd break NICs which do not support
TSO6.

Instead of adding an ad-hoc ethtool function in the neterion driver,
we should either add a new ethtool function which sets both TSO/TSO6,
or do the following.

> Alternatively, we can add a new features bit which gives the inherent
> features of a device.  That can then be used to derive the actual
> features in use.  That way we won't need to invent a new ethtool
> helper function for this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
