From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net+crypto: Use vmalloc for zlib inflate buffers.
Date: Tue, 28 Jun 2011 12:57:27 +0800
Message-ID: <20110628045727.GA22502@gondor.apana.org.au>
References: <20110627.212618.657750275676567934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	mjackson220.list@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34168 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab1F1E5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:57:32 -0400
Content-Disposition: inline
In-Reply-To: <20110627.212618.657750275676567934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 09:26:18PM -0700, David Miller wrote:
> 
> They are 64K and result in order-4 allocations, even with SLUB.
> 
> Therefore, just like we always have for the deflate buffers, use
> vmalloc.
> 
> Reported-by: Martin Jackson <mjackson220.list@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
