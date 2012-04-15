From: David Miller <davem@davemloft.net>
Subject: Re: [0/3] bridge: Do not send multicast queries by default
Date: Sun, 15 Apr 2012 12:52:25 -0400 (EDT)
Message-ID: <20120415.125225.1400564852542689459.davem@davemloft.net>
References: <20120413123641.GA758@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755713Ab2DOQy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 12:54:26 -0400
In-Reply-To: <20120413123641.GA758@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Fri, 13 Apr 2012 20:36:41 +0800

> This series of patches is aimed to change the default multicast
> snooping behaviour to one that is safer to deploy in the wild.
> 
> There have been numerous reports of switches misbehaving with
> our current behaviour of sending general queries, presumably
> because we're using a zero source IP address which is unavoidable
> as using anything else would interfere with multicast querier
> elections (incidentally, I noticed that our IPv6 code has been
> "fixed" to not use zero source addresses, which is wrong as we
> may end up being THE MLD querier in a network).
> 
> Since our queries aren't actually required for multicast snooping
> to function, but is merely an optimisation mostly for faster
> start-up convergence, I think we should disable this by default.

All applied to net-next, thanks Herbert.
