From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [for-next 07/10] IB/mlx5: Use blue flame register allocator in
 mlx5_ib
Date: Thu, 05 Jan 2017 14:51:57 -0500 (EST)
Message-ID: <20170105.145157.1792441048386916850.davem@davemloft.net>
References: <1483480528-22622-1-git-send-email-saeedm@mellanox.com>
        <1483480528-22622-8-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483480528-22622-8-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Tue,  3 Jan 2017 23:55:25 +0200

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
> index ddb4ca4..39505ac 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
> @@ -5,7 +5,7 @@
>  config MLX5_CORE
>  	tristate "Mellanox Technologies ConnectX-4 and Connect-IB core driver"
>  	depends on MAY_USE_DEVLINK
> -	depends on PCI
> +	depends on PCI && 64BIT
>  	default n
>  	---help---
>  	  Core driver for low level functionality of the ConnectX-4 and

This is a regression, I'm not applying this.

I don't care how hard it is, you have to keep the driver building properly
in non-64bit builds.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
