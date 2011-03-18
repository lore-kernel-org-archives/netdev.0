From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/36] net,rcu: convert call_rcu(xps_map_release) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:36:34 -0700 (PDT)
Message-ID: <20110318.123634.28816134.davem@davemloft.net>
References: <4D82D94C.2090507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, eric.dumazet@gmail.com,
	therbert@google.com, ebiederm@xmission.com, gregkh@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82D94C.2090507@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:02:20 +0800

> 
> 
> The rcu callback xps_map_release() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(xps_map_release).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
