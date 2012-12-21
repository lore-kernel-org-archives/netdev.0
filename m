From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: arp: fix a lockdep splat in arp_solicit()
Date: Fri, 21 Dec 2012 13:16:04 -0800 (PST)
Message-ID: <20121221.131604.630440467916062914.davem@davemloft.net>
References: <1356111130.21834.7565.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yanb@mellanox.com, shemminger@vyatta.com
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab2LUVQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 16:16:06 -0500
In-Reply-To: <1356111130.21834.7565.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Fri, 21 Dec 2012 09:32:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Yan Burman reported following lockdep warning :
 ...
> Bug is from arp_solicit(), releasing the neigh lock after arp_send()
> In case of vxlan, we eventually need to write lock a neigh lock later.
> 
> Its a false positive, but we can get rid of it without lockdep
> annotations.
> 
> We can instead use neigh_ha_snapshot() helper.
> 
> Reported-by: Yan Burman <yanb@mellanox.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
