From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] bonding: patchset for rcu use in
 bonding
Date: Thu, 17 Oct 2013 15:32:44 -0400 (EDT)
Message-ID: <20131017.153244.222608241064658402.davem@davemloft.net>
References: <525CFCAF.2000605@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758209Ab3JQTcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:32:47 -0400
In-Reply-To: <525CFCAF.2000605@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 15 Oct 2013 16:28:31 +0800

> The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
> dd rtnl lock and remove read lock for bond sysfs.
> 
> v2 because the bond_for_each_slave_rcu without rcu_read_lock() will occurs one warming, so
> add new function for alb xmit path to avoid warming.

Series applied, thanks.
