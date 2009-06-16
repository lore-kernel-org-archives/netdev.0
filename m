From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Wed, 17 Jun 2009 02:38:56 +1000
Message-ID: <20090616163856.GA17318@gondor.apana.org.au>
References: <20090529162312.GA5191@neterion.com> <20090610054449.GB16984@gondor.apana.org.au> <20090612160926.GA4290@neterion.com> <20090612.164833.35888001.davem@davemloft.net> <20090616163547.GC5013@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <ben.lahaise@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40824 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758330AbZFPQi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 12:38:59 -0400
Content-Disposition: inline
In-Reply-To: <20090616163547.GC5013@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2009 at 12:35:47PM -0400, Benjamin LaHaise wrote:
> On Fri, Jun 12, 2009 at 04:48:33PM -0700, David Miller wrote:
> > I find a 500Mbps difference, due to just one single cache miss on
> > every packet, simply astounding and unbelievable.  But hey, it is
> > what you are seeing, so something has to account for it. :)
> 
> The cache miss only accounts for ~50Mbpsi, it'd be nice if there was an 
> easy way to get the whole 500Mbps back.  The rest seems to be in the 
> general overhead of the GRO code vs the normal NAPI rx path.  The P4 
> Xeon is substantially worse at string operations than the Core 2 / Core i7 
> based Xeons, so I'm hoping to test and see if they do any better with the 
> GRO code when I get access to a new machine soon.

I'm hoping to get onto this tomorrow.  I think there's definitely
something broken because there's no way GRO should be slower than
GRO off.  Slightly slower than LRO perhaps but surely not worse than
not merging at all :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
