From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove rcu locking from fib_rules_event()
Date: Wed, 10 Mar 2010 07:35:18 -0800 (PST)
Message-ID: <20100310.073518.54055177.davem@davemloft.net>
References: <1268201018.2872.139.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756743Ab0CJPe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:34:58 -0500
In-Reply-To: <1268201018.2872.139.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Mar 2010 07:03:38 +0100

> We hold RTNL at this point and dont use RCU variants of list traversals,
> we dont need rcu_read_lock()/rcu_read_unlock()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this, but to my net-next-2.6 tree once I open that
up.
