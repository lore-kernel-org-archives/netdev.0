From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for-next 03/11] IB/mlx5: Add helper
 mlx5_ib_post_send_wait
Date: Sun, 01 Jan 2017 21:10:26 -0500 (EST)
Message-ID: <20170101.211026.2671529442746711.davem@davemloft.net>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
        <1483305027-2573-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, binoy.jayan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483305027-2573-4-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Sun,  1 Jan 2017 23:10:19 +0200

> diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
> index 8f608deb..afb6dc1 100644
> --- a/drivers/infiniband/hw/mlx5/mr.c
> +++ b/drivers/infiniband/hw/mlx5/mr.c
> @@ -891,16 +891,40 @@ static inline void mlx5_ib_init_umr_context(struct mlx5_ib_umr_context *context)
>  	init_completion(&context->done);
>  }
>  
> +static inline int mlx5_ib_post_send_wait(struct mlx5_ib_dev *dev,
> +					 struct mlx5_umr_wr *umrwr)

Please do not use 'inline' in foo.c files, let the compiler decide.

I know this is already happening in this file, but that should be
continued rather than replicated further.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
