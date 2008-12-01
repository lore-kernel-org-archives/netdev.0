From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 4/5] crypto: allow allocation of percpu crypto
	transforms
Date: Mon, 1 Dec 2008 19:38:28 +0800
Message-ID: <20081201113828.GA20961@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201071943.GT476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50928 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751570AbYLALic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 06:38:32 -0500
Content-Disposition: inline
In-Reply-To: <20081201071943.GT476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 08:19:43AM +0100, Steffen Klassert wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> 
> This patch adds functions to alloc/free crypto transforms
> as percpu data.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I'd prefer to just have the user call crypto_alloc_tfm for each
CPU.  This is the slow path after all so we don't need to optimise
it that much.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
