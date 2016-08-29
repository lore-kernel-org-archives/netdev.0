From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/9] Mellanox 100G mlx5 fixes 2016-08-29
Date: Sun, 28 Aug 2016 23:31:46 -0400 (EDT)
Message-ID: <20160828.233146.701497700884731451.davem@davemloft.net>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbcH2Dby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 23:31:54 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Mon, 29 Aug 2016 01:13:41 +0300

> This series contains some bug fixes for the mlx5 core and mlx5
> ethernet driver.
> 
> From Saeed, Fix UMR to consider hardware translation table field
> size limitation when calculating the maximum number of MTTs required
> by the driver.  Three patches to speed-up netdevice close time by
> serializing channel (SQs & RQs) destruction rather than issuing and
> waiting for hardware interrupts to free them.
> 
> From Eran, Fix ethtool ring parameter reporting for striding RQ layout.
> Add error prints on ETS validation failure.
> 
> From Kamal, Fix memory leak on error flow.
> 
> From Maor, Fix ethtool steering priorities number.

Series applied.

> For -stable of 4.7.y:
>   net/mlx5e: Limit UMR length to the device's limitation
>   net/mlx5e: Don't wait for RQ completions on close 
>   net/mlx5e: Don't post fragmented MPWQE when RQ is disabled
>   net/mlx5e: Don't wait for SQ completions on close
>   net/mlx5e: Add ethtool counter for TX xmit_more

Queued up, thanks.
