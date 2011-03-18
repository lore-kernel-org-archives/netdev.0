From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/36] net,rcu: convert
 call_rcu(netlbl_unlhsh_free_addr4) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:36:51 -0700 (PDT)
Message-ID: <20110318.123651.245394297.davem@davemloft.net>
References: <4D82D9AC.30205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82D9AC.30205@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:03:56 +0800

> 
> 
> The rcu callback netlbl_unlhsh_free_addr4() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(netlbl_unlhsh_free_addr4).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
