From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reintroduce missing rcu_assign_pointer() calls
Date: Thu, 12 Jan 2012 12:27:17 -0800 (PST)
Message-ID: <20120112.122717.786146992871306558.davem@davemloft.net>
References: <1326376603.2950.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326379292.2950.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215Ab2ALU1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 15:27:46 -0500
In-Reply-To: <1326379292.2950.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jan 2012 15:41:32 +0100

> commit a9b3cd7f32 (rcu: convert uses of rcu_assign_pointer(x, NULL) to
> RCU_INIT_POINTER) did a lot of incorrect changes, since it did a
> complete conversion of rcu_assign_pointer(x, y) to RCU_INIT_POINTER(x,
> y).
> 
> We miss needed barriers, even on x86, when y is not NULL.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Applied, thanks Eric.
