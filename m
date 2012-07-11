From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 17:29:08 -0700 (PDT)
Message-ID: <20120710.172908.745359979722998717.davem@davemloft.net>
References: <20120710.080714.2272376193166978850.davem@davemloft.net>
	<1341939724.6118.145.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123Ab2GKA3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 20:29:19 -0400
In-Reply-To: <1341939724.6118.145.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 10 Jul 2012 10:02:04 -0700

> Maybe something like this is a bit more legible?
> {
> 	if (a->family != b->family)
> 		return false;
> 
> 	if (a->family == AF_INET)
> 		return a->addr.a4 == b->addr.a4;
> 
> 	return ipv6_addr_equal((const struct in6_addr *)&a->addr.a6,
> 			       (const struct in6_addr *)&b->addr.a6);
> }

My version was meant to be fast rather than legible :-)
