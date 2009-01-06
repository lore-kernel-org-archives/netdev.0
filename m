From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ixgbe select_queue broken in 2.6.28
Date: Wed, 07 Jan 2009 00:02:55 +1100
Message-ID: <E1LKBaB-0007kB-7f@gondolin.me.apana.org.au>
References: <Pine.WNT.4.64.0901041918010.1888@ppwaskie-MOBL2.amr.corp.intel.com>
Cc: davem@davemloft.net, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com (Waskiewicz Jr, Peter P)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46521 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751630AbZAFNDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 08:03:06 -0500
In-Reply-To: <Pine.WNT.4.64.0901041918010.1888@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:
> 
> I understand why you want to remove this, but at the same time it is 
> something that is useful if we don't abuse it.  I know for a fact this 
> function pointer is very useful for routing performance setups, where 
> binding a Tx queue to the CPU is very useful.  Jesse actually did the work 
> on testing and getting good results with this.

Sure.  But that is not driver-specific.  The only reason to do
an override is if the hash needs to be driver-specific.  So far
the only reasons that have been given are deficiencies in the
current hash, rather than a genuine need by the driver.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
