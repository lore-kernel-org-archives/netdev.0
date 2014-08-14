From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: HELP: IPsec reordering issue
Date: Thu, 14 Aug 2014 16:47:40 +0800
Message-ID: <20140814084740.GA30846@gondor.apana.org.au>
References: <53D9B2EE.5040002@gmail.com>
 <20140731062321.GA2957@gondor.apana.org.au>
 <53DE0772.2090106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Xue Ying <ying.xue@windriver.com>
To: Ming Liu <liu.ming50@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53DE0772.2090106@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 03, 2014 at 05:57:06PM +0800, Ming Liu wrote:
> 
> Please review this attached patch instead, the original one has a
> problem causing the kernel crash.

Thanks for the patch.  I think it would better to enforce ordering
for all operations rather than treat encryptions separately from
decryptions.  We could conceivably have more complex operations made
up from both encryptions and decryptions that could then get
out-of-order.

It would also make the code simpler.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
