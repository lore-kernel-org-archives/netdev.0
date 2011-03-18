From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 28/36] net,rcu: convert
 call_rcu(phonet_device_rcu_free) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:37:16 -0700 (PDT)
Message-ID: <20110318.123716.229752161.davem@davemloft.net>
References: <4D82DADF.4010802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu,
	remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932721Ab1CRTgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:36:39 -0400
In-Reply-To: <4D82DADF.4010802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:09:03 +0800

> 
> 
> The rcu callback phonet_device_rcu_free() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(phonet_device_rcu_free).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
