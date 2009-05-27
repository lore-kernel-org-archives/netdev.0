From: David Miller <davem@davemloft.net>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Wed, 27 May 2009 03:42:03 -0700 (PDT)
Message-ID: <20090527.034203.230063441.davem@davemloft.net>
References: <20090527044539.GA32372@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38365
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759611AbZE0KmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 06:42:04 -0400
In-Reply-To: <20090527044539.GA32372@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 27 May 2009 14:45:39 +1000

> This series of patches brings GRO performance to within 1% of LRO
> on the slow machine that I was testing.  I can overtake LRO by
> deleting the IP checksum test and the Ethernet header test from
> GRO, which LRO doesn't do anyway, but that's not very nice :)
> 
> I'm still looking at other optimisations as time allows.

All applied to net-next-2.6, thanks Herbert!
