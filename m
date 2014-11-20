From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Thu, 20 Nov 2014 15:43:42 +0800
Message-ID: <20141120074342.GA29544@gondor.apana.org.au>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
 <20141115031549.GA19208@gondor.apana.org.au>
 <20141120072650.GT6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Liu <ming.liu@windriver.com>, davem@davemloft.net,
	ying.xue@windriver.com, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141120072650.GT6390@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 08:26:51AM +0100, Steffen Klassert wrote:
>
> What about to use a fallback algorithm that does not need to touch
> FPU/SIMD in such cases? We would not need cryptd at all and it would
> keep the requests in the right order because we don't defer them.

This would be bad for throughput since the fallback is many orders
of magnitude slower than aesni.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
