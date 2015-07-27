From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] ConnectX-4 driver update 2015-07-23
Date: Mon, 27 Jul 2015 00:29:35 -0700 (PDT)
Message-ID: <20150727.002935.331423638651507396.davem@davemloft.net>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, achiad@mellanox.com, ogerlitz@mellanox.com,
	talal@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbbG0H3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 03:29:36 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 23 Jul 2015 23:35:55 +0300

> This patchset introduce some performance enhancements to the ConnectX-4 driver.
> 1. Improving RSS distribution, and make RSS function controlable using ethtool.
> 2. Make memory that is written by NIC and read by host CPU allocate in the
>    local NUMA to the processing CPU
> 3. Support tx copybreak
> 4. Using hardware feature called blueflame to save DMA reads when possible
> 
> Another patch by Achiad fix some cosmetic issues in the driver.
> 
> Patchset was applied and tested on top of commit 045a0fa ("ip_tunnel: Call
> ip_tunnel_core_init() from inet_init()")

Series applied, thanks.
