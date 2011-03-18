From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/36] net,rcu: convert call_rcu(free_dm_hw_stat) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:35:28 -0700 (PDT)
Message-ID: <20110318.123528.71127686.davem@davemloft.net>
References: <4D82D071.5020703@cn.fujitsu.com>
	<4D82D3FF.2080303@cn.fujitsu.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756818Ab1CRTeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:34:50 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 11:39:43 +0800

> 
> 
> The rcu callback free_dm_hw_stat() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(free_dm_hw_stat).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
