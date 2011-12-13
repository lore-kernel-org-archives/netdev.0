From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_gred: should not use GFP_KERNEL while holding a
 spinlock
Date: Mon, 12 Dec 2011 19:09:50 -0500 (EST)
Message-ID: <20111212.190950.2203832047174673834.davem@davemloft.net>
References: <1323682973.2948.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311Ab1LMAJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 19:09:52 -0500
In-Reply-To: <1323682973.2948.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 12 Dec 2011 10:42:53 +0100

> gred_change_vq() is called under sch_tree_lock(sch).
> 
> This means a spinlock is held, and we are not allowed to sleep in this
> context.
> 
> We might pre-allocate memory using GFP_KERNEL before taking spinlock,
> but this is not suitable for stable material.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
