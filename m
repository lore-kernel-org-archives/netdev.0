From: David Miller <davem@davemloft.net>
Subject: Re: |PATCH net-next] net: treewide use of RCU_INIT_POINTER
Date: Wed, 23 Nov 2011 19:08:17 -0500 (EST)
Message-ID: <20111123.190817.2280105658719138407.davem@davemloft.net>
References: <1322068172.17693.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab1KXAIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 19:08:22 -0500
In-Reply-To: <1322068172.17693.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Nov 2011 18:09:32 +0100

> rcu_assign_pointer(ptr, NULL) can be safely replaced by
> RCU_INIT_POINTER(ptr, NULL)
> 
> (old rcu_assign_pointer() macro was testing the NULL value and could
> omit the smp_wmb(), but this had to be removed because of compiler
> warnings)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
