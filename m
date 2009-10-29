From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce dev_get_by_index_rcu()
Date: Thu, 29 Oct 2009 01:43:20 -0700 (PDT)
Message-ID: <20091029.014320.29385522.davem@davemloft.net>
References: <4ADD44B0.8030204@gmail.com>
	<20091020140632.79efb738@s6510>
	<4ADD4839.9010500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50408
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751835AbZJ2Im4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:42:56 -0400
In-Reply-To: <4ADD4839.9010500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2009 07:18:49 +0200

> [PATCH net-next-2.6] net: Introduce dev_get_by_index_rcu()
> 
> Some workloads hit dev_base_lock rwlock pretty hard.
> We can use RCU lookups to avoid touching this rwlock.
> 
> netdevices are already freed after a RCU grace period, so this patch
> adds no penalty at device dismantle time.
> 
> dev_ifname() converted to dev_get_by_index_rcu()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks!
