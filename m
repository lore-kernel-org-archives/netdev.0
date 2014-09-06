From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix a race in update_or_create_fnhe()
Date: Fri, 05 Sep 2014 17:16:30 -0700 (PDT)
Message-ID: <20140905.171630.1706805599539767486.davem@davemloft.net>
References: <1409808116.26422.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbaIFAQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:16:31 -0400
In-Reply-To: <1409808116.26422.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Sep 2014 22:21:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> nh_exceptions is effectively used under rcu, but lacks proper
> barriers. Between kzalloc() and setting of nh->nh_exceptions(),
> we need a proper memory barrier.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 4895c771c7f00 ("ipv4: Add FIB nexthop exceptions.")

Applied, thanks Eric.
