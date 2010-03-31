From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] flow: structurize flow cache
Date: Wed, 31 Mar 2010 19:21:21 +0800
Message-ID: <20100331112121.GE12845@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-6-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:43899 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932317Ab0CaLVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:21:23 -0400
Content-Disposition: inline
In-Reply-To: <1270030626-16687-6-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 01:17:06PM +0300, Timo Teras wrote:
> Group all per-cpu data to one structure instead of having many
> globals. Also prepare the internals so that we can have multiple
> instances of the flow cache if needed.
> 
> Only the kmem_cache is left as a global as all flow caches share
> the same element size, and benefit from using a common cache.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
