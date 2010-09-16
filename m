From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/3] ipip: get rid of ipip_lock
Date: Wed, 15 Sep 2010 19:31:03 -0700 (PDT)
Message-ID: <20100915.193103.220050908.davem@davemloft.net>
References: <1284584844.2462.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350Ab0IPCap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 22:30:45 -0400
In-Reply-To: <1284584844.2462.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Sep 2010 23:07:24 +0200

> As RTNL is held while doing tunnels inserts and deletes, we can remove
> ipip_lock spinlock. My initial RCU conversion was conservative and
> converted the rwlock to spinlock, with no RTNL requirement.
> 
> Use appropriate rcu annotations and modern lockdep checks as well.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
