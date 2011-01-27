From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: fix dev_seq_next()
Date: Thu, 27 Jan 2011 14:22:41 -0800 (PST)
Message-ID: <20110127.142241.189706868.davem@davemloft.net>
References: <1296101282.1783.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751915Ab1A0WWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:22:07 -0500
In-Reply-To: <1296101282.1783.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Jan 2011 05:08:02 +0100

> [PATCH net-next-2.6] net: fix dev_seq_next()
> 
> Commit c6d14c84566d (net: Introduce for_each_netdev_rcu() iterator)
> added a race in dev_seq_next().
> 
> The rcu_dereference() call should be done _before_ testing the end of
> list, or we might return a wrong net_device if a concurrent thread
> changes net_device list under us.
> 
> Note : discovered thanks to a sparse warning :
> 
> net/core/dev.c:3919:9: error: incompatible types in comparison expression
> (different address spaces)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Applied.
