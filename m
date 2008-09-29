From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 17:43:52 +0800
Message-ID: <20080929094352.GA25273@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru> <20080929070213.GA24146@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39528 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751269AbYI2Jn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 05:43:59 -0400
Content-Disposition: inline
In-Reply-To: <20080929070213.GA24146@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 03:02:13PM +0800, Herbert Xu wrote:
>
> OK you're on FV as well.  I'll try it on my laptaop next.

Interesting.  On my laptop I'm seeing 113MB/s with TSO on and
119MB/s without.  However, netperf shows TSO on is slightly
better than TSO off (4716Mb/s vs. 4680Mb/s).

A packet dump on tbench indicates it's sending lots of small
packets so TSO wouldn't be contributing anything positive at
all.  Hmm, it seems that even netperf isn't producing anything
larger than MTU so something seems amiss with the TCP stack.

BTW what were the actual numbers on your machine with tbench?
And what about netperf?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
