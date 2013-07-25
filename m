From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 v2] bonding: don't call slave_xxx_netpoll under
 spinlocks
Date: Wed, 24 Jul 2013 17:45:47 -0700 (PDT)
Message-ID: <20130724.174547.131365101717202321.davem@davemloft.net>
References: <51EE2FE7.4040605@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590Ab3GYApt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:45:49 -0400
In-Reply-To: <51EE2FE7.4040605@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 23 Jul 2013 15:25:27 +0800

> The slave_xxx_netpoll will call synchronize_rcu_bh(),
> so the function may schedule and sleep, it should't be
> called under spinlocks.
> 
> bond_netpoll_setup() and bond_netpoll_cleanup() are always
> protected by rtnl lock, it is no need to take the read lock,
> as the slave list couldn't be changed outside rtnl lock.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
