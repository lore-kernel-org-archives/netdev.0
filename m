From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add missing UFO initialisations
Date: Thu, 13 Jul 2006 22:04:34 -0700 (PDT)
Message-ID: <20060713.220434.66181695.davem@davemloft.net>
References: <20060713091101.GA28651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22497
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964792AbWGNFEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 01:04:34 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060713091101.GA28651@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Jul 2006 19:11:01 +1000

> [NET]: Add missing UFO initialisations
> 
> This bug was unknowingly fixed the GSO patches (or rather, its effect was
> unknown at the time).
> 
> Thanks to Marco Berizzi's persistence which is documented in the thread
> "ipsec tunnel asymmetrical mtu", we now know that it can have highly
> non-obvious symptoms.
> 
> What happens is that uninitialised uso_size fields can cause packets to
> be incorrectly identified as UFO, which means that it does not get
> fragmented even if it's over the MTU.
> 
> The fix is simple enough.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Signed-off-by: David S. Miller <davem@davemloft.net>
