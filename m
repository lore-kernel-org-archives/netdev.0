From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 30/36] net,rcu: convert call_rcu(wq_free_rcu) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:37:22 -0700 (PDT)
Message-ID: <20110318.123722.35043418.davem@davemloft.net>
References: <4D82DB31.7050007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932733Ab1CRTgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:36:44 -0400
In-Reply-To: <4D82DB31.7050007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:10:25 +0800

> 
> 
> The rcu callback wq_free_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(wq_free_rcu).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
