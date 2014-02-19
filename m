From: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: net,IB/mlx: Bump all Mellanox driver versions
Date: Wed, 19 Feb 2014 18:23:18 +0200
Message-ID: <20140219162315.GA10262@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1392824851-8667-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392824851-8667-1-git-send-email-amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 19/02/14 17:47 +0200, Amir Vadai wrote:
> Bump all Mellanox driver versions.
> 
> Signed-off-by: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> ---
> Hi,
> 
> We're changing the version scheme of our drivers.
> I would be happy if it goes to net. Also, added here drivers from rdma tree,
> because I would like it to be unified accorss all Mellanox's drivers.
> 
> Thanks,
> Amir
> 
>  drivers/infiniband/hw/mlx4/main.c              | 4 ++--
>  drivers/infiniband/hw/mlx5/main.c              | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h      | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 4 ++--
>  drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 ++--
>  5 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
> index e81c554..f9c12e9 100644
> --- a/drivers/infiniband/hw/mlx4/main.c
> +++ b/drivers/infiniband/hw/mlx4/main.c
> @@ -53,8 +53,8 @@
>  #include "user.h"
>  
>  #define DRV_NAME	MLX4_IB_DRV_NAME
> -#define DRV_VERSION	"1.0"
> -#define DRV_RELDATE	"April 4, 2008"
> +#define DRV_VERSION	"2.2-1"
> +#define DRV_RELDATE	"Feb 2014"
>  
>  #define MLX4_IB_FLOW_MAX_PRIO 0xFFF
>  #define MLX4_IB_FLOW_QPN_MASK 0xFFFFFF
> diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
> index aa03e73..bf90057 100644
> --- a/drivers/infiniband/hw/mlx5/main.c
> +++ b/drivers/infiniband/hw/mlx5/main.c
> @@ -46,8 +46,8 @@
>  #include "mlx5_ib.h"
>  
>  #define DRIVER_NAME "mlx5_ib"
> -#define DRIVER_VERSION "1.0"
> -#define DRIVER_RELDATE	"June 2013"
> +#define DRIVER_VERSION "2.2-1"
> +#define DRIVER_RELDATE	"Feb 2014"
>  
>  MODULE_AUTHOR("Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>");
>  MODULE_DESCRIPTION("Mellanox Connect-IB HCA IB driver");
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> index 6b65f77..7aec6c8 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> @@ -51,8 +51,8 @@
>  
>  #define DRV_NAME	"mlx4_core"
>  #define PFX		DRV_NAME ": "
> -#define DRV_VERSION	"1.1"
> -#define DRV_RELDATE	"Dec, 2011"
> +#define DRV_VERSION	"2.2-1"
> +#define DRV_RELDATE	"Feb, 2014"
>  
>  #define MLX4_FS_UDP_UC_EN		(1 << 1)
>  #define MLX4_FS_TCP_UC_EN		(1 << 2)
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 9ca223b..b57e8c8 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -57,8 +57,8 @@
>  #include "en_port.h"
>  
>  #define DRV_NAME	"mlx4_en"
> -#define DRV_VERSION	"2.0"
> -#define DRV_RELDATE	"Dec 2011"
> +#define DRV_VERSION	"2.2-1"
> +#define DRV_RELDATE	"Feb 2014"
>  
>  #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
>  
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> index a064f06..23b7e2d 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> @@ -46,8 +46,8 @@
>  #include "mlx5_core.h"
>  
>  #define DRIVER_NAME "mlx5_core"
> -#define DRIVER_VERSION "1.0"
> -#define DRIVER_RELDATE	"June 2013"
> +#define DRIVER_VERSION "2.2-1"
> +#define DRIVER_RELDATE	"Feb 2014"
>  
>  MODULE_AUTHOR("Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>");
>  MODULE_DESCRIPTION("Mellanox ConnectX-IB HCA core library");
> -- 
> 1.8.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Adding linux-rdma and Roland to the CC

Amir
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
