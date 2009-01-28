From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
	hashing.
Date: Thu, 29 Jan 2009 08:31:41 +1100
Message-ID: <20090128213141.GD22141@gondor.apana.org.au>
References: <20090127.164027.245779962.davem@davemloft.net> <20090128085358.GA15593@gondor.apana.org.au> <20090128.122231.208600152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44762 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751121AbZA1Vbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 16:31:44 -0500
Content-Disposition: inline
In-Reply-To: <20090128.122231.208600152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 12:22:31PM -0800, David Miller wrote:
>
> No matter what you think about the randomness aspect, our
> divide avoidance technique being used here will still
> get in the way of the situations you seem to be concerned
> about.
> 
> We do the jhash et al. magic in order to be able to use a
> multiply to get the modulus.  So the function computing from
> RX to TX queue numbers will never be straightforward.

Right, if the number of queues weren't equal then clearly it's
not an issue to tack on more randomness.  But I was thinking of
scenarios where you have two identical NICs, performing routing
where the number of queues is likely to be identical.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
