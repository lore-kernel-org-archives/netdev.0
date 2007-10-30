From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 1/2] [CRYPTO] tcrypt: Move sg_init_table out of timing
	loops
Date: Tue, 30 Oct 2007 15:17:54 +0100
Message-ID: <20071030141754.GT4993@kernel.dk>
References: <20071026145905.GA13850@gondor.apana.org.au> <E1IlQfM-0003cO-00@gondolin.me.apana.org.au> <20071029201627.GD7499@kernel.dk> <20071030000827.GA9037@gondor.apana.org.au> <20071030055056.GG7499@kernel.dk> <20071030141820.GA16501@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755958AbXJ3OUk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071030141820.GA16501@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30 2007, Herbert Xu wrote:
> On Tue, Oct 30, 2007 at 06:50:58AM +0100, Jens Axboe wrote:
> >
> > How so? The reason you changed it to sg_init_table() + sg_set_buf() is
> > exactly because sg_init_one() didn't properly init the entry (as they
> > name promised).
> 
> For one of the cases yes but the other one repeatedly calls
> sg_init_one on the same sg entry while we really only need
> to initialise it once and call sg_set_buf afterwards.
> 
> Normally this is irrelevant but the loops in question are
> trying to estimate the speed of the algorithms so it's good
> to exclude as much noise from them as possible.

Ah OK, I was referring to the replacement mentioned above.

-- 
Jens Axboe
