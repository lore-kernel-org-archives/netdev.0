From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 14:46:04 +0100
Message-ID: <20071031134604.GP5059@kernel.dk>
References: <20071030.204002.193703502.davem@davemloft.net> <20071031134518.GA27412@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:10257 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756088AbXJaNsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 09:48:46 -0400
Content-Disposition: inline
In-Reply-To: <20071031134518.GA27412@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31 2007, Herbert Xu wrote:
> On Tue, Oct 30, 2007 at 08:40:02PM -0700, David Miller wrote:
> > 
> > I just checked the following bug fix into net-2.6
> 
> Thanks for getting to the bottom of this Dave! I seem to have
> mistaken the = for a |= in sg_mark_end :)

I don't blame you, that function was definitely non-intuitive!

-- 
Jens Axboe

