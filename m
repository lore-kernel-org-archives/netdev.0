From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/36] macvlan,rcu: convert
 call_rcu(macvlan_port_rcu_free) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:36:17 -0700 (PDT)
Message-ID: <20110318.123617.48501741.davem@davemloft.net>
References: <4D82D8C7.3040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82D8C7.3040608@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:00:07 +0800

> 
> 
> The rcu callback macvlan_port_rcu_free() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(macvlan_port_rcu_free).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
