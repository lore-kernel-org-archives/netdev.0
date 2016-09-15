From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Thu, 15 Sep 2016 19:21:06 -0400 (EDT)
Message-ID: <20160915.192106.739428651744920778.davem@davemloft.net>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbcIOXVJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:21:09 -0400
In-Reply-To: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 12 Sep 2016 16:20:11 +0300

> This patchset contains some bug fixes, a cleanup, and small improvements
> from the team to the mlx4 Eth and core drivers.
> 
> Series generated against net-next commit:
> 02154927c115 "net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device"
> 
> Please push the following patch to -stable  >= 4.6 as well:
> "net/mlx4_core: Fix to clean devlink resources"

Again, coding style fixes and optimizations like branch prediction
hints are not bug fixes and therefore not appropriate for 'net'.
