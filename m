From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/3] Mellanox, mlx5 fixes 2017-06-28
Date: Sat, 01 Jul 2017 14:17:18 -0700 (PDT)
Message-ID: <20170701.141718.339311478562486532.davem@davemloft.net>
References: <20170630071229.20357-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752108AbdGAVRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 17:17:20 -0400
In-Reply-To: <20170630071229.20357-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Fri, 30 Jun 2017 10:12:26 +0300

> This series contains some fixes for the mlx5 core and netdev driver.
> 
> Please pull and let me know if there's any problem.
> 
> For -stable:
> ("net/mlx5e: Fix TX carrier errors report in get stats ndo") Kernels >= v4.7
> 
> ("net/mlx5: Cancel delayed recovery work when unloading the driver") Kernels >= v4.10
> * When applied to net-next this will introduce a contextual conflict, it
> should be easy to resolve, (a spin_lock was changed to spin_lock_irqsave in net-next),
> if you need any help with this please let me know.
> 
> ("net/mlx5: Fix driver load error flow when firmware is stuck") Kernels >= v4.4*
> * This patch fixes: 6c780a0267b8 ("net/mlx5: Wait for FW readiness before initializing command interface")
> which was submitted two weeks ago and queued up for v4.4.
> 
> Sorry about the mess, but other than the above, this series doesn't introduce
> any conflict with the current mlx5 IPSec offload series.

Pulled and queued up for -stable, thanks.

I should be able to resolve the merge conflicts, thanks for letting
me know about it.
