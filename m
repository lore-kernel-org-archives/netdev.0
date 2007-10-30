From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [CRYPTO] tcrypt: Move sg_init_table out of timing loops
Date: Tue, 30 Oct 2007 08:08:27 +0800
Message-ID: <20071030000827.GA9037@gondor.apana.org.au>
References: <20071026145905.GA13850@gondor.apana.org.au> <E1IlQfM-0003cO-00@gondolin.me.apana.org.au> <20071029201627.GD7499@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071029201627.GD7499@kernel.dk>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 09:16:27PM +0100, Jens Axboe wrote:
> On Fri, Oct 26 2007, Herbert Xu wrote:
> > [CRYPTO] tcrypt: Move sg_init_table out of timing loops
> > 
> > This patch moves the sg_init_table out of the timing loops for hash
> > algorithms so that it doesn't impact on the speed test results.
> 
> Wouldn't it be better to just make sg_init_one() call sg_init_table?

This looks fine to me although I think it's orthogonal to the
patch you were quoting :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
