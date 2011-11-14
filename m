From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Fix] mlx4_en: Remove FCS bytes from packet length.
Date: Mon, 14 Nov 2011 00:13:30 -0500 (EST)
Message-ID: <20111114.001330.804008773505285450.davem@davemloft.net>
References: <4EBF733E.5020801@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab1KNFNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:13:37 -0500
In-Reply-To: <4EBF733E.5020801@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 13 Nov 2011 09:35:26 +0200

> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 8fda331c..d93476b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -140,6 +140,7 @@ enum {
>  #define MLX4_EN_TX_POLL_TIMEOUT	(HZ / 4)
>  
>  #define ETH_LLC_SNAP_SIZE	8
> +#define FCS_SIZE		4
>  

Please use ETH_FCS_LEN from linux/if_ether.h
