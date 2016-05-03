From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] Mellanox 100G mlx5 fixes for 4.6-rc
Date: Tue, 03 May 2016 13:37:47 -0400 (EDT)
Message-ID: <20160503.133747.1459772515243143845.davem@davemloft.net>
References: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934338AbcECRhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 13:37:52 -0400
In-Reply-To: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun,  1 May 2016 22:59:53 +0300

> This small series provides some bug fixes for mlx5 driver.
>  
> A small bug fix for iounmap of a null pointer, which dumps a warning on some archs.
> 
> One patch to fix the VXLAN/MLX5_EN dependency issue reported by Arnd.
> 
> Two patches to fix the scheduling while atomic issue for ndo_add/del_vxlan_port 
> NDOs.  The first will add an internal mlx5e workqueue and the second will 
> delegate vxlan ports add/del requests to that workqueue.
> 
> Note: ('net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue') is only needed for net 
> and not net-next as the issue was globally fixed for all device drivers by:
> b7aade15485a ('vxlan: break dependency with netdev drivers') in net-next.
> 
> Applied on top: f27337e16f2d ('ip_tunnel: fix preempt warning in ip tunnel creation/updating')

Series applied, thanks.
