From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Fri, 16 Jan 2009 19:56:45 +1100
Message-ID: <20090116085645.GA14678@gondor.apana.org.au>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56546 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755049AbZAPI4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 03:56:54 -0500
Content-Disposition: inline
In-Reply-To: <49704015.6020503@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 12:06:45AM -0800, Divy Le Ray wrote:
> 
> The perfs are not actually as good as with LRO.

Thanks for testing Divy!

> With a slow server, 1 netperf stream gets on average:

I presume the server is receiving?

> without the patch, lro off: 3.8Gbs
> without the patch, lro on: 6.1Gbs
> with the patch, GRO on: 4.8Gbs.

What about the case of GRO off with the patch? Just checking to
make sure that nothing else has changed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
