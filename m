From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Fix truncation length of authentication
	algorithms installed via PF_KEY
Date: Fri, 11 Dec 2009 14:28:56 +0800
Message-ID: <20091211062856.GC28849@gondor.apana.org.au>
References: <1260375075-16187-1-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260375075-16187-1-git-send-email-martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 09, 2009 at 05:11:15PM +0100, Martin Willi wrote:
> Commit 4447bb33f09444920a8f1d89e1540137429351b6 breaks installation of
> authentication algorithms via PF_KEY, as the state specific truncation
> length is not installed with the algorithms default truncation length.
> This patch initializes state properly to the default if installed via
> PF_KEY.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
