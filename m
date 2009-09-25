From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 14:45:05 -0700
Message-ID: <20090925214505.GA3472@gondor.apana.org.au>
References: <1253731834.2538.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32864 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752257AbZIYVpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:45:07 -0400
Content-Disposition: inline
In-Reply-To: <1253731834.2538.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:
>
>> That's a bummer.  I'm guessing you might get close to right on average with some
>> trivial math, but if someone is sending you pkts with size of 1000 and
>> your MTU is 1500, would there be any way to tell that the pkts were originally
>> 1000 bytes instead of 1500?
> 
> Good point.

Well if you did GRO instead of LRO then none of this would matter :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
