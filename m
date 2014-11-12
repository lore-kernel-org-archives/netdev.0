From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Wed, 12 Nov 2014 16:51:48 +0800
Message-ID: <20141112085148.GA26268@gondor.apana.org.au>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Liu <ming.liu@windriver.com>, davem@davemloft.net,
	ying.xue@windriver.com, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141112084138.GL6390@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 09:41:38AM +0100, Steffen Klassert wrote:
>
> Can't we just use cryptd unconditionally to fix this reordering problem?

I think the idea is that most of the time cryptd isn't required
so we want to stick with direct processing to lower latency.

I think the simplest fix would be to punt to cryptd as long as
there are cryptd requests queued.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
