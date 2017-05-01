From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlxsw: spectrum_router: Simplify VRF
 enslavement
Date: Sun, 30 Apr 2017 23:04:48 -0400 (EDT)
Message-ID: <20170430.230448.383130211524258207.davem@davemloft.net>
References: <20170430164714.7303-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, mlxsw@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968750AbdEADEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 23:04:49 -0400
In-Reply-To: <20170430164714.7303-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <idosch@mellanox.com>
Date: Sun, 30 Apr 2017 19:47:14 +0300

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When a netdev is enslaved to a VRF master, its router interface (RIF)
> needs to be destroyed (if exists) and a new one created using the
> corresponding virtual router (VR).
> 
> From the driver's perspective, the above is equivalent to an inetaddr
> event sent for this netdev. Therefore, when a port netdev (or its
> uppers) are enslaved to a VRF master, call the same function that
> would've been called had a NETDEV_UP was sent for this netdev in the
> inetaddr notification chain.
> 
> This patch also fixes a bug when a LAG netdev with an existing RIF is
> enslaved to a VRF. Before this patch, each LAG port would drop the
> reference on the RIF, but would re-join the same one (in the wrong VR)
> soon after. With this patch, the corresponding RIF is first destroyed
> and a new one is created using the correct VR.
> 
> Fixes: 7179eb5acd59 ("mlxsw: spectrum_router: Add support for VRFs")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
