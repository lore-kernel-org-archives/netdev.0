From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4] IB/ipoib: Add rtnl_link_ops support
Date: Thu, 20 Sep 2012 16:58:12 -0400 (EDT)
Message-ID: <20120920.165812.1484686663057692048.davem@davemloft.net>
References: <1347551797-2495-1-git-send-email-ogerlitz@mellanox.com>
	<1347551797-2495-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, erezsh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab2ITU6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 16:58:14 -0400
In-Reply-To: <1347551797-2495-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 13 Sep 2012 18:56:36 +0300

> Add rtnl_link_ops to IPoIB, with the first usage being child device
> create/delete through them. Childs devices are now either legacy ones,
> created/deleted through the ipoib sysfs entries, or RTNL ones.
> 
> Adding support for RTNL childs involved refactoring of ipoib_vlan_add
> which is now used by both the sysfs and the link_ops code.
> 
> Also, added ndo_uninit entry to support calling unregister_netdevice_queue
> from the rtnl dellink entry. This required removal of calls to
> ipoib_dev_cleanup from the driver in flows which use unregister_netdevice,
> since the networking core will invoke ipoib_uninit which does exactly that.
> 
> Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied to net-next, thanks.
