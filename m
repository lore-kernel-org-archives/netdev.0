From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 15:10:41 -0700
Message-ID: <20090925221041.GA3853@gondor.apana.org.au>
References: <1253915790.3809.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43684 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752654AbZIYWKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:10:40 -0400
Content-Disposition: inline
In-Reply-To: <1253915790.3809.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:
>
>> Well if you did GRO instead of LRO then none of this would matter :)
> 
> ixgbe uses GRO, but we have HW RSC/LRO running on 82599 adapters
> underneath GRO.

I know.  What I was suggesting is that the hardware should also
switch away from LRO to GRO, i.e., restrict what you merge so that
resegmentation can be performed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
