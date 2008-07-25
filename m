From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec: ipcomp - Decompress into frags if necessary
Date: Fri, 25 Jul 2008 18:46:03 +0800
Message-ID: <20080725104603.GA17974@gondor.apana.org.au>
References: <E1KM0Wl-0001zC-00@gondolin.me.apana.org.au> <20080725074109.GA16747@gondor.apana.org.au> <20080725074328.GB16747@gondor.apana.org.au> <20080725.025801.229691344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58645 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751833AbYGYKqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:46:12 -0400
Content-Disposition: inline
In-Reply-To: <20080725.025801.229691344.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 02:58:01AM -0700, David Miller wrote:
>
> Actually I wonder if it's even possible.  Our limit is 64K anyways
> (and that's our scratch buffer size) and MAX_SKB_FRAGS is always
> large enough to accomodate at least 64K of data.

Right it shouldn't be possible right now.

> So perhaps it wants a WARN_ON :-)

There is one :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
