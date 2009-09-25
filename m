From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 15:01:15 -0700
Message-ID: <20090925220115.GA3684@gondor.apana.org.au>
References: <20090925214505.GA3472@gondor.apana.org.au> <4ABD3B34.8010903@candelatech.com> <20090925.145915.68839478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53851 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750992AbZIYWBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:01:16 -0400
Content-Disposition: inline
In-Reply-To: <20090925.145915.68839478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2009 at 02:59:15PM -0700, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Fri, 25 Sep 2009 14:50:44 -0700
> 
> > I get aggregate 18Gbps with LRO v/s 12Gbps without, so it's very
> > much a useful feature for me.
> 
> And it'll stay like that until you work with Herbert to fix
> that performance difference.

Actually I believe he's talking about hardware LRO which is a
different beast.

AFAICS the ixgbe driver doesn't use software LRO anymore.

So if it is hardware LRO then what we need is for the hardware
to switch over :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
