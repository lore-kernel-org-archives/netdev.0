From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/36] net,rcu: convert call_rcu(__gen_kill_estimator)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:35:47 -0700 (PDT)
Message-ID: <20110318.123547.112592113.davem@davemloft.net>
References: <4D82D071.5020703@cn.fujitsu.com>
	<4D82D3FF.2080303@cn.fujitsu.com>
	<4D82D4DE.60105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, axboe@kernel.dk,
	robert.w.love@intel.com, James.Bottomley@suse.de,
	nhorman@tuxdriver.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tj@kernel.org,
	jarkao2@gmail.com, linux-kernel@vger.kernel.org,
	devel@open-fcoe.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D82D4DE.60105@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 11:43:26 +0800

> 
> 
> The rcu callback __gen_kill_estimator() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(__gen_kill_estimator).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
