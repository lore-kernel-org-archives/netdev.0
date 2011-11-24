From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
	input routes
Date: Thu, 24 Nov 2011 20:06:48 +0800
Message-ID: <20111124120648.GB18807@gondor.apana.org.au>
References: <20111123155245.GA11638@gondor.apana.org.au> <20111123.164941.1950228526500366081.davem@davemloft.net> <20111124001035.GA14996@gondor.apana.org.au> <20111123.191758.1061988020384521241.davem@davemloft.net> <20111124010147.GA15318@gondor.apana.org.au> <20111124084952.GF6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50791 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab1KXMG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 07:06:57 -0500
Content-Disposition: inline
In-Reply-To: <20111124084952.GF6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 09:49:52AM +0100, Steffen Klassert wrote:
>
> Well, it simply got unpredictable how long pmtu propagation takes.
> This depends now on the network activity of the routers and on the
> individual configuration of the expiration time on each router. With
> the original behaviour, we could expect to notice a pmtu increase
> if we probe after our timeout X. Now we don't know when this is going
> to happen.

With IPsec tunnel mode this already happens to an extent anyway.
Any PMTU event outside the tunnel is invisible to hosts within it.
Only the router can see those events.

However, as I said I'm not too bothered with this so feel free
to go with your patch.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
