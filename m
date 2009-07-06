From: David Miller <davem@davemloft.net>
Subject: Re: flow director and packet ordering
Date: Sun, 05 Jul 2009 18:59:56 -0700 (PDT)
Message-ID: <20090705.185956.121092946.davem@davemloft.net>
References: <20090705041955.GA7892@gondor.apana.org.au>
	<20090705.155354.85683961.davem@davemloft.net>
	<20090706011051.GB15156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38214
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751709AbZGFB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 21:59:49 -0400
In-Reply-To: <20090706011051.GB15156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 6 Jul 2009 09:10:51 +0800

> In that case I don't see the big need in moving the flows/sockets
> after establishment.  After all process migration should be rare,
> so if it does occur then it's OK for the existing sockets to stay
> on their original queue.

I personally assume that a master process that accepts connections
and then hands them off down to worker threads is quite common.

> I'm curious about what the limit on the number of flows is though.
> Because when you go above that limit performance will magically
> suck :)

Yes, of course that's an important aspect of the implementation.
