From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip6tnl: get rid of ip6_tnl_lock
Date: Thu, 16 Sep 2010 21:59:03 -0700 (PDT)
Message-ID: <20100916.215903.45135629.davem@davemloft.net>
References: <1284618334.2462.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42364
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750860Ab0IQE6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 00:58:44 -0400
In-Reply-To: <1284618334.2462.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Sep 2010 08:25:34 +0200

> As RTNL is held while doing tunnels inserts and deletes, we can remove
> ip6_tnl_lock spinlock. My initial RCU conversion was conservative and
> converted the rwlock to spinlock, with no RTNL requirement.
> 
> Use appropriate rcu annotations and modern lockdep checks as well.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
