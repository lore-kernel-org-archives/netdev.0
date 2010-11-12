From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 V2] igmp: RCU conversion of in_dev->mc_list
Date: Fri, 12 Nov 2010 13:19:36 -0800 (PST)
Message-ID: <20101112.131936.191390015.davem@davemloft.net>
References: <1289568858.3185.252.camel@edumazet-laptop>
	<1289571974.3185.254.camel@edumazet-laptop>
	<1289576810.3185.261.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, cypher.w@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932796Ab0KLVTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 16:19:12 -0500
In-Reply-To: <1289576810.3185.261.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Nov 2010 16:46:50 +0100

> [PATCH net-next-2.6 V2] igmp: RCU conversion of in_dev->mc_list
> 
> in_dev->mc_list is protected by one rwlock (in_dev->mc_list_lock).
> 
> This can easily be converted to a RCU protection.
> 
> Writers hold RTNL, so mc_list_lock is removed, not replaced by a
> spinlock.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This looks good to me, so I've applied it to net-next-2.6

We have enough time there to fix any fallout or revert if
necessary.
