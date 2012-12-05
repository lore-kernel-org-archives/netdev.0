From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: avoid taking locks at socket dismantle
Date: Wed, 05 Dec 2012 16:26:20 -0500 (EST)
Message-ID: <20121205.162620.378864065213200277.davem@davemloft.net>
References: <1354735090.31222.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab2LEV0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:26:22 -0500
In-Reply-To: <1354735090.31222.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Dec 2012 11:18:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> ipv6_sock_mc_close() is called for ipv6 sockets at close time, and most
> of them don't use multicast.
> 
> Add a test to avoid contention on a shared spinlock.
> 
> Same heuristic applies for ipv6_sock_ac_close(), to avoid contention
> on a shared rwlock.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
