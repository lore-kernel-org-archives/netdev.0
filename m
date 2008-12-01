From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 5/5] crypto: make struct aead percpu data
Date: Mon, 1 Dec 2008 19:40:00 +0800
Message-ID: <20081201114000.GB20961@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201072043.GU476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50934 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751449AbYLALkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 06:40:03 -0500
Content-Disposition: inline
In-Reply-To: <20081201072043.GU476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 08:20:43AM +0100, Steffen Klassert wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> 
> The struct aead is now allocated as percpu data to get
> rid of a very high contended lock in crypto_authenc_hash()
> if IPsec runs in parallel.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Well you're in luck :) One of the objectives of the shash work
is to get rid of this lock.  So instead of doing this, please
push the shash work along and we can eliminate this without
allocating loads of duplicate tfm's.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
