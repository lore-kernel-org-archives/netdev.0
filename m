From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Mar 2010 23:08:13 +0800
Message-ID: <20100329150813.GA26393@gondor.apana.org.au>
References: <20100328082250.GA14053@gondor.apana.org.au> <20100328.055312.58421329.davem@davemloft.net> <20100328131112.GA15984@gondor.apana.org.au> <20100328.064012.193708716.davem@davemloft.net> <20100328135931.GA16430@gondor.apana.org.au> <20100328143235.GA16694@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48571 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752272Ab0C2PIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 11:08:17 -0400
Content-Disposition: inline
In-Reply-To: <20100328143235.GA16694@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 28, 2010 at 10:32:35PM +0800, Herbert Xu wrote:
> 
> Here's a convoluted scheme that I just thought up as a compromise
> between your wish to expel the metrics and maintaining the policy
> routing semantics.

I think the bigger question is are we now ready for a per-cpu
route cache?

The route cache is one of the few remaining global structures
that is standing in the way of full multicore scalability.

Or is there another way of solving this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
