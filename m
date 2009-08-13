From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
 __xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Wed, 12 Aug 2009 21:18:35 -0700 (PDT)
Message-ID: <20090812.211835.120888237.davem@davemloft.net>
References: <20090813035310.GA19182@gondor.apana.org.au>
	<20090812.205635.244644770.davem@davemloft.net>
	<20090813041115.GA19344@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43267
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbZHMESZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:18:25 -0400
In-Reply-To: <20090813041115.GA19344@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Aug 2009 14:11:15 +1000

> Some IPsec applications use a policy that spawns one SA per
> src/dst address pair.  In that case, even an entity that is
> not on the IPsec side would be able to spawn SAs with the intent
> of causing collisions.  It simply needs to send packets through
> the IPsec gateway with the appropriate destination addresses.

Ok, all good points.  We need to do something about this.

So probably we need to eat jhash after all.

Resistence is futile, sigh :-)
