From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] Mellanox mlx5e fixes for 4.11-rc1
Date: Thu, 23 Feb 2017 10:44:15 -0500 (EST)
Message-ID: <20170223.104415.922556148345528493.davem@davemloft.net>
References: <20170222152016.31263-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751609AbdBWPoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 10:44:20 -0500
In-Reply-To: <20170222152016.31263-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 22 Feb 2017 17:20:10 +0200

> This series includes some important bug fixes for mlx5e driver.
> 
> Three misc fixes:
> From Mohamad, compilation fix on s390 system
> From Me, A fix for driver unload when switchdev mode is on. 
> From Tariq, HW LRO frag size optimization for when build_skb is not used
> (striding RQ mode).
> 
> Three CQE compression related fixes:
> Two fixes from Tariq and I, to correctly setup CQE compression
> parameters on driver load and on arbitrary user modifications.
> Last patch, fixes a very critical issue that was originally reported
> by Tom, where the driver reported csum errors or even page ref issues
> for when cqe compression is enabled and rapidly active.
> 
> For your convenience this series was generated on top of net-next branch:
> 005c3490e9db ('Revert "ath10k: Search SMBIOS for OEM board file extension"')

Series applied.

> for -stable:
> net/mlx5e: Register/unregister vport representors on interface (for kernel >= 4.9)
> net/mlx5e: Do not reduce LRO WQE size when not using build_skb (for kernel >= 4.9)
> net/mlx5e: Fix broken CQE compression initialization (for kernel >= 4.9)
> net/mlx5e: Update MPWQE stride size when modifying CQE compress state (for kernel >= 4.7)
> net/mlx5e: Fix wrong CQE decompression (for kernel >= 4.7)

Queued up, thanks.
