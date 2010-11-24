From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: mcast: RCU conversion
Date: Wed, 24 Nov 2010 11:17:02 -0800 (PST)
Message-ID: <20101124.111702.28794135.davem@davemloft.net>
References: <1290553935.2866.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754854Ab0KXTQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:16:36 -0500
In-Reply-To: <1290553935.2866.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Nov 2010 00:12:15 +0100

> ipv6_sk_mc_lock rwlock becomes a spinlock.
> 
> readers (inet6_mc_check()) now takes rcu_read_lock() instead of read
> lock. Writers dont need to disable BH anymore.
> 
> struct ipv6_mc_socklist objects are reclaimed after one RCU grace
> period.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
