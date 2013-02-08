From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] net/mlx4_en: Add support for unicast
 MAC filtering and FDB operations
Date: Thu, 07 Feb 2013 23:27:28 -0500 (EST)
Message-ID: <20130207.232728.968013808381909167.davem@davemloft.net>
References: <1360239927-758-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, yanb@mellanox.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab3BHE1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:27:32 -0500
In-Reply-To: <1360239927-758-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu,  7 Feb 2013 14:25:18 +0200

> This series from Yan Burman adds support for unicast MAC address filtering and
> ndo FDB operations.  It also includes some optimizations to loopback related
> decisions and checks in the TX/RX fast path and one cleanup, all in separate
> patches.
> 
> Today, when adding macvlan devices, the NIC goes into promiscuous mode, since
> unicast MAC filtering is not supported. With these changes, macvlan devices can
> be added without the penalty of promiscuous mode.
> 
> If for some reason adding a unicast address filter fails e.g as of missing space in
> the HW mac table, the device forces itself into promiscuous mode (and out of this
> forced state when enough space is available).
> 
> Also, now it is possible to have bridge under multi-function configuration that include
> PF and VFs.  In order to use bridge over PF/VFs, VM MAC fdb entries must be added e.g.
> using 'bridge fdb add' command.

Series applied, thanks.
