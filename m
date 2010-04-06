From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Tue, 6 Apr 2010 20:34:04 +0800
Message-ID: <20100406123404.GA24294@gondor.apana.org.au>
References: <20100405091228.GA17059@gondor.apana.org.au> <1270486884-10905-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49062 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753319Ab0DFMeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:34:09 -0400
Content-Disposition: inline
In-Reply-To: <1270486884-10905-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 08:01:24PM +0300, Timo Teras wrote:
> This allows to validate the cached object before returning it.
> It also allows to destruct object properly, if the last reference
> was held in flow cache. This is also a prepartion for caching
> bundles in the flow cache.
> 
> In return for virtualizing the methods, we save on:
> - not having to regenerate the whole flow cache on policy removal:
>   each flow matching a killed policy gets refreshed as the getter
>   function notices it smartly.
> - we do not have to call flow_cache_flush from policy gc, since the
>   flow cache now properly deletes the object if it had any references
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks a lot for the patch!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
