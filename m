From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 21:45:18 +0800
Message-ID: <20071031134518.GA27412@gondor.apana.org.au>
References: <20071030.204002.193703502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4680 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756959AbXJaNpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 09:45:25 -0400
Content-Disposition: inline
In-Reply-To: <20071030.204002.193703502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 08:40:02PM -0700, David Miller wrote:
> 
> I just checked the following bug fix into net-2.6

Thanks for getting to the bottom of this Dave! I seem to have
mistaken the = for a |= in sg_mark_end :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
