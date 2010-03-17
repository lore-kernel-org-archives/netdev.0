From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove rcu locking from fib_rules_event()
Date: Tue, 16 Mar 2010 21:28:46 -0700 (PDT)
Message-ID: <20100316.212846.160081359.davem@davemloft.net>
References: <1268201018.2872.139.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36022
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831Ab0CQE2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:28:24 -0400
In-Reply-To: <1268201018.2872.139.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Mar 2010 07:03:38 +0100

> We hold RTNL at this point and dont use RCU variants of list traversals,
> we dont need rcu_read_lock()/rcu_read_unlock()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
