From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 15:09:06 -0700
Message-ID: <20090925220906.GA3818@gondor.apana.org.au>
References: <4ABD3B34.8010903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43676 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751591AbZIYWJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:09:05 -0400
Content-Disposition: inline
In-Reply-To: <4ABD3B34.8010903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> wrote:
>
>> Well if you did GRO instead of LRO then none of this would matter :)
> 
> I get aggregate 18Gbps with LRO v/s 12Gbps without, so it's very much a useful feature
> for me.

Sorry we are each talking about different things.  The performance
difference you observed is software GRO vs. hardware LRO.  What I
was talking about above is switching the Intel hardware to do GRO
instead of LRO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
