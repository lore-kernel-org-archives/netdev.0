From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 10:38:09 +0800
Message-ID: <20090729023809.GA2218@gondor.apana.org.au>
References: <20090729012523.GA1583@gondor.apana.org.au> <20090728.183451.93398827.davem@davemloft.net> <20090729021212.GA1946@gondor.apana.org.au> <20090728.192247.247655474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58014 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754406AbZG2CiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 22:38:18 -0400
Content-Disposition: inline
In-Reply-To: <20090728.192247.247655474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 07:22:47PM -0700, David Miller wrote:
> 
> Of course, you can solve the issue by redefining problem. :-)
> 
> However, such a semantic is not what users of this feature
> are after.  I doubt there would be much uptake of it even
> if we did implement it.

I did say it wasn't a good answer :)

My main point is that whatever we do for the limiting qdiscs
should not penalise the non-limiting qdiscs because for the
moment people are trying to get more out of their NICs rather
than less :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
