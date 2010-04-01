From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Thu, 1 Apr 2010 08:22:44 +0800
Message-ID: <20100401002244.GA18893@gondor.apana.org.au>
References: <20100331135505.GC14082@gondor.apana.org.au> <1270044768.26743.58.camel@bigi> <20100331141525.GA14331@gondor.apana.org.au> <20100331.135735.00480230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:55771 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750795Ab0DAAXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:23:04 -0400
Content-Disposition: inline
In-Reply-To: <20100331.135735.00480230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 01:57:35PM -0700, David Miller wrote:
> 
> Herbert, if it doesn't break anything, I feel the gains are very
> worthwhile.

OK, in that case please change xfrm_state_flush too.  Right now
it also notifies on empty.

> Have you actually tried to monitor the IPSEC netlink socket events
> when a daemon is running?  It's way too painful before Jamal's
> changes, and we already emit way too many semantically empty events in
> netlink.

Honestly I can't see how eliminating an empty flush event helps.
Flushes are very rare.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
