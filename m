From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/36] net,rcu: convert call_rcu(net_generic_release)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:37:04 -0700 (PDT)
Message-ID: <20110318.123704.70191230.davem@davemloft.net>
References: <4D82DA48.2070305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, jpirko@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82DA48.2070305@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:06:32 +0800

> 
> 
> The rcu callback net_generic_release() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(net_generic_release).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
