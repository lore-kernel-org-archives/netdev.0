From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 00/12] net: ethernet: aquantia:
 improvements and fixes
Date: Mon, 20 Feb 2017 17:12:15 -0500 (EST)
Message-ID: <20170220.171215.1879925433871766656.davem@davemloft.net>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon.Edelhaus@aquantia.com,
        Alexey.Andriyanov@aquantia.com, LinoSanfilippo@gmx.de
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdBTWMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 17:12:25 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Mon, 20 Feb 2017 22:36:38 +0300

> The following patchset contains improvements and fixes for aQuantia
> AQtion ethernet driver from net-next tree.
> 
> Most fixes are based on the comments from Lino Sanfilippo.
> 
> Sanity testing was performed on real HW. No regression found.
> 
> v1->v2: 1)Removed buffers copying.
> 	2)Fixed dma error handling.
> 
> v2->v3: 1)Fixes for aq_ndev_change_mtu:
> 	-Use core MTU checking for min_mtu.
> 	-Removed extra new_mtu assigment.
> 	2)Reverse XMAS tree in aq_ring_rx_fill.
> v3->v4: 1)Use ndev->reg_state instead "is_ndev_registered" flag.

Series applied.
