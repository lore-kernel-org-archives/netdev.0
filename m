From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Thu, 28 May 2009 09:08:58 +1000
Message-ID: <20090527230858.GA24278@gondor.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au> <20090527175223.GB7804@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <ben.lahaise@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55811 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750850AbZE0XJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 19:09:01 -0400
Content-Disposition: inline
In-Reply-To: <20090527175223.GB7804@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2009 at 01:52:23PM -0400, Benjamin LaHaise wrote:
> 
> A few questions for you: I've been looking a bit into potential GRO 
> optimisations that are possible with the vxge driver.  At least from my 
> existing testing on a P4 Xeon, it seems that doing packet rx via 
> napi_gro_receive() was a bit slower.  I'll retest with these changes 

Slower compared to LRO or GRO off?

> of yours.  What platform have your tests been run on?  Also, do you have 
> any notes/ideas on how best to make use of the GRO functionality within 
> the kernel?  I'm hoping it's possible to make use of a few of the hardware 
> hints to improve fast path performance.

What sort of hints do you have?

There aren't any current support for that but I'm happy to add
things as appropriate.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
