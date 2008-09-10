From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 10 Sep 2008 13:15:59 +1000
Message-ID: <20080910031559.GA27430@gondor.apana.org.au>
References: <20080903053935.GA8428@gondor.apana.org.au> <48BE245D.3060905@iki.fi> <20080903055041.GA8547@gondor.apana.org.au> <20080909.200400.96645840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53108 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751779AbYIJDQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 23:16:07 -0400
Content-Disposition: inline
In-Reply-To: <20080909.200400.96645840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 08:04:00PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 3 Sep 2008 15:50:41 +1000
> 
> > ipsec: Move state dump list unlinking into GC
> > 
> > This patch moves the unlinking of x->all (for dumping) into the
> > GC so that we know for sure what locks we hold when we unlink the
> > entry.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> After your patch I just applied, things are a bit different now.
> 
> Are you going to respin this or is it not relevant any longer?

This patch is now redundant.

What could be done though is to remove x->all and restore the
original walking by hashing.  This would eliminate a list node
from xfrm_state, and would also restore the original dump ordering.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
