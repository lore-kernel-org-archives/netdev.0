From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH 2/7] crypto: authenc - convert to ahash
Date: Mon, 20 Jul 2009 14:55:14 +0800
Message-ID: <20090720065514.GB4026@gondor.apana.org.au>
References: <20090716111548.GP20288@secunet.com> <20090716111747.GR20288@secunet.com> <20090717.100334.160030992.davem@davemloft.net> <20090720062643.GA20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47686 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751882AbZGTGzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 02:55:19 -0400
Content-Disposition: inline
In-Reply-To: <20090720062643.GA20288@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2009 at 08:26:43AM +0200, Steffen Klassert wrote:
>
> We have sg_mark_end() which sets the termination bit on a sg list entry,
> but we don't have an interface to remove the termination bit from a sg
> list entry. 

For the case at hand, as we've agreed to only do the chaining
if there is only a single entry in the list, we don't need this
at all.  All you need to do is copy the page pointer, offset and
length without copying the raw scatterlist entry.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
