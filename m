From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] garp: remove one synchronize_rcu() call
Date: Mon, 09 May 2011 20:25:52 +0200
Message-ID: <4DC831B0.80107@trash.net>
References: <1304948155.3342.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57633 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab1EISZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:25:54 -0400
In-Reply-To: <1304948155.3342.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.05.2011 15:35, schrieb Eric Dumazet:
> Speedup vlan dismantling in CONFIG_VLAN_8021Q_GVRP=y cases,
> by using a call_rcu() to free the memory instead of waiting with
> expensive synchronize_rcu() [ while RTNL is held ]
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> Note: I'll take care of using kfree_rcu() when available in net-next-2.6
> 

Looks good to me.

