From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 20:56:37 -0700 (PDT)
Message-ID: <20120710.205637.571556391010747247.davem@davemloft.net>
References: <1341967486.13724.9.camel@joe2Laptop>
	<20120710.180137.2161994914932724530.davem@davemloft.net>
	<1341969736.13724.32.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab2GKD4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 23:56:40 -0400
In-Reply-To: <1341969736.13724.32.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 10 Jul 2012 18:22:16 -0700

> If it's IPv4, 
> 
> 	if (a->family == AF_INET)
> 		return a->addr.a4 == b->addr.a4;
> 
> 	return ipv6_addr_equal((const struct in6_addr *)&a->addr.a6,
> 			       (const struct in6_addr *)&b->addr.a6);
> 
> so it's a single word test or a 4 word test.

Fair enough.
