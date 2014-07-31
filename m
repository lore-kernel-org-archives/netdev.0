From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: HELP: IPsec reordering issue
Date: Thu, 31 Jul 2014 14:23:21 +0800
Message-ID: <20140731062321.GA2957@gondor.apana.org.au>
References: <53D9B2EE.5040002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Xue Ying <ying.xue@windriver.com>
To: Ming Liu <liu.ming50@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53D9B2EE.5040002@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 31, 2014 at 11:07:26AM +0800, Ming Liu wrote:
>
> And we've figure out a patch as the attached, the basic idea is just
> queue the packets if "irq_fpu_usable()" is not usable or if there
> are already few packets queued for decryption. Else decrypt the
> packets.

Yes your description makes sense and I will review your patch
for inclusion.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
