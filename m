From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 17:24:30 -0800 (PST)
Message-ID: <20090113.172430.177897618.davem@davemloft.net>
References: <20090113.161625.111759506.davem@davemloft.net>
	<20090114005110.GA6814@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754733AbZANBY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 20:24:29 -0500
In-Reply-To: <20090114005110.GA6814@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Jan 2009 11:51:10 +1100

> We can probably do that for spliced data that end up going to
> the networking stack again.  However, as splice is generic the
> data may be headed to a destination other than the network stack.
> 
> In that case to make dataref work we'd need some mechanism
> that allows non-network entities to get/drop this ref count.

I see.

I'll think about this some more.
