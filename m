From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Wed, 17 Jun 2009 16:08:47 +0800
Message-ID: <20090617080847.GA24504@gondor.apana.org.au>
References: <20090529162312.GA5191@neterion.com> <20090610054449.GB16984@gondor.apana.org.au> <20090612160926.GA4290@neterion.com> <20090612.164833.35888001.davem@davemloft.net> <20090616163547.GC5013@neterion.com> <20090616163856.GA17318@gondor.apana.org.au> <20090617080730.GA24410@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <ben.lahaise@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58041 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754647AbZFQIIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 04:08:51 -0400
Content-Disposition: inline
In-Reply-To: <20090617080730.GA24410@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 04:07:30PM +0800, Herbert Xu wrote:
> On Wed, Jun 17, 2009 at 02:38:56AM +1000, Herbert Xu wrote:
> > 
> > I'm hoping to get onto this tomorrow.  I think there's definitely
> > something broken because there's no way GRO should be slower than
> > GRO off.  Slightly slower than LRO perhaps but surely not worse than
> > not merging at all :)
> 
> OK, I'm seeing the opposite :)

Can you check your sender to see whether it's maxed out? That
can play havoc when benchmarking the receiver.

Also what are the raw numbers that you were getting?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
