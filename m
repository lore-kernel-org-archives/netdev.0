From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/36] net,rcu: convert call_rcu(xps_dev_maps_release)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:36:39 -0700 (PDT)
Message-ID: <20110318.123639.102547986.davem@davemloft.net>
References: <4D82D967.7090408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, mingo@elte.hu, eric.dumazet@gmail.com,
	therbert@google.com, ebiederm@xmission.com, gregkh@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932112Ab1CRTgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:36:02 -0400
In-Reply-To: <4D82D967.7090408@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:02:47 +0800

> 
> 
> The rcu callback xps_dev_maps_release() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(xps_dev_maps_release).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
