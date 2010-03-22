From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sun, 21 Mar 2010 18:28:46 -0700 (PDT)
Message-ID: <20100321.182846.232914131.davem@davemloft.net>
References: <20100319093210.GA23895@gondor.apana.org.au>
	<4BA349A8.9050105@iki.fi>
	<20100320151751.GB2950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753578Ab0CVB2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:28:23 -0400
In-Reply-To: <20100320151751.GB2950@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 20 Mar 2010 23:17:51 +0800

> Actually I just realised that the other way we can fix this is
> to make xfrm_dst objects per-cpu just like IPv4 routes.  That
> is, when you fail to find an xfrm_dst object in the per-cpu
> cache, you dont' bother calling xfrm_find_bundle but just make
> a new bundle.

How are ipv4 routing cache entries per-cpu?  That would screw up route
metrics for TCP sockets quite a lot if they were.
