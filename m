From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: flow director and packet ordering
Date: Mon, 6 Jul 2009 09:10:51 +0800
Message-ID: <20090706011051.GB15156@gondor.apana.org.au>
References: <20090616.023132.194401812.davem@davemloft.net> <20090705041955.GA7892@gondor.apana.org.au> <20090705.155354.85683961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58621 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759AbZGFBKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 21:10:53 -0400
Content-Disposition: inline
In-Reply-To: <20090705.155354.85683961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 03:53:54PM -0700, David Miller wrote:
>
> Flows map to queues, queues don't move.  Rather the mapping between
> flows and queues changes dynamically.

Oh that makes more sense.

In that case I don't see the big need in moving the flows/sockets
after establishment.  After all process migration should be rare,
so if it does occur then it's OK for the existing sockets to stay
on their original queue.

I'm curious about what the limit on the number of flows is though.
Because when you go above that limit performance will magically
suck :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
