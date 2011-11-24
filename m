From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
	input routes
Date: Thu, 24 Nov 2011 09:01:47 +0800
Message-ID: <20111124010147.GA15318@gondor.apana.org.au>
References: <20111123155245.GA11638@gondor.apana.org.au> <20111123.164941.1950228526500366081.davem@davemloft.net> <20111124001035.GA14996@gondor.apana.org.au> <20111123.191758.1061988020384521241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47856 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab1KXBBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 20:01:52 -0500
Content-Disposition: inline
In-Reply-To: <20111123.191758.1061988020384521241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 07:17:58PM -0500, David Miller wrote:
>
> It means there is a propagation delay of PMTU increasing which is on the
> order of the number of hops between the sender and the PMTU increased link.
> So if the PMTU timeout is X, the propagation time is X * N_HOPS.

That assumes that each router in the path would constantly probe
to refresh its cached value, as otherwise they should all expire
after X.

However, as this was the original behaviour, I think going back to
it is fine.

I am curious in knowing exactly what scenario Steffen ran into
that prompted this change though.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
