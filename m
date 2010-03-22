From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Mon, 22 Mar 2010 09:32:57 +0800
Message-ID: <20100322013257.GA14080@gondor.apana.org.au>
References: <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <20100321.182846.232914131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40835 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753744Ab0CVBdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:33:06 -0400
Content-Disposition: inline
In-Reply-To: <20100321.182846.232914131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 06:28:46PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 20 Mar 2010 23:17:51 +0800
> 
> > Actually I just realised that the other way we can fix this is
> > to make xfrm_dst objects per-cpu just like IPv4 routes.  That
> > is, when you fail to find an xfrm_dst object in the per-cpu
> > cache, you dont' bother calling xfrm_find_bundle but just make
> > a new bundle.
> 
> How are ipv4 routing cache entries per-cpu?  That would screw up route
> metrics for TCP sockets quite a lot if they were.

You're right of course, s/just like IPv4 routes// :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
