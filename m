From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: rt_cache_valid must check expired routes
Date: Wed, 25 Jul 2012 15:25:21 -0700 (PDT)
Message-ID: <20120725.152521.661459480578969849.davem@davemloft.net>
References: <1343229083.2626.11177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab2GYWZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:25:22 -0400
In-Reply-To: <1343229083.2626.11177.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jul 2012 17:11:23 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
> introduced rt_cache_valid() helper. It unfortunately doesn't check if
> route is expired before caching it.
> 
> I noticed sk_setup_caps() was constantly called on a tcp workload.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

> ---
> This patch is bringed by an European guy, but its still July after
> all ;)

:-)
