From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 36/36] net,rcu: convert
 call_rcu(xt_osf_finger_free_rcu) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:37:28 -0700 (PDT)
Message-ID: <20110318.123728.15237339.davem@davemloft.net>
References: <4D82DC46.5010905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82DC46.5010905@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:15:02 +0800

> 
> 
> The rcu callback xt_osf_finger_free_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(xt_osf_finger_free_rcu).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
