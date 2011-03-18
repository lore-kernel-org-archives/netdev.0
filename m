From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/36] net,rcu: convert
 call_rcu(ipv6_mc_socklist_reclaim) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:36:22 -0700 (PDT)
Message-ID: <20110318.123622.260084841.davem@davemloft.net>
References: <4D82D8F2.5020208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60267
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932591Ab1CRTfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:35:45 -0400
In-Reply-To: <4D82D8F2.5020208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:00:50 +0800

> 
> 
> The rcu callback ipv6_mc_socklist_reclaim() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(ipv6_mc_socklist_reclaim).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
