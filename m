From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Sat, 13 Dec 2008 09:49:54 +1100
Message-ID: <20081212224954.GA11636@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au> <1229112677.3051.9.camel@achroite> <20081212214835.GD11046@gondor.apana.org.au> <1229121327.3051.69.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47191 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753775AbYLLWuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 17:50:03 -0500
Content-Disposition: inline
In-Reply-To: <1229121327.3051.69.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 10:35:27PM +0000, Ben Hutchings wrote:
>
> If I'm not mistaken, the whole point of set_flags() is to end the
> continued expansion of struct ethtool_ops by another 2 functions for
> every new offload feature.  The comments make it fairly clear that Jeff
> anticipated that it might be necessary to include such checks for some
> flags.

GRO is purely a stack feature so it doesn't need anything in
ethtool_ops at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
