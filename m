From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Fix to clean devlink resources
Date: Thu, 22 Sep 2016 01:41:43 -0400 (EDT)
Message-ID: <20160922.014143.604703967863844795.davem@davemloft.net>
References: <1474372531-27120-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, kamalh@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbcIVFlq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:41:46 -0400
In-Reply-To: <1474372531-27120-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 20 Sep 2016 14:55:31 +0300

> From: Kamal Heib <kamalh@mellanox.com>
> 
> This patch cleans devlink resources by calling devlink_port_unregister()
> to avoid the following issues:
> 
> - Kernel panic when triggering reset flow.
> - Memory leak due to unfreed resources in mlx4_init_port_info().
> 
> Fixes: 09d4d087cd48 ("mlx4: Implement devlink interface")
> Signed-off-by: Kamal Heib <kamalh@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---
> Please push it to -stable  >= 4.6 as well. Thanks.

Applied and queued up for -stable, thanks.
