From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] mlx4_en: make mlx4_log_num_mgm_entry_size static
Date: Mon, 3 Jul 2017 09:09:56 +0300
Message-ID: <20170703060954.GA2784@yuvallap>
References: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499060119-7063-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2017 at 01:35:19AM -0400, Zhu Yanjun wrote:
> The variable mlx4_log_num_mgm_entry_size is only called in main.c.
> 
> CC: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> CC: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 2 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h | 1 -
>  2 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 83aab1e..4b67277 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -91,7 +91,7 @@ module_param_array(probe_vf, byte, &probe_vfs_argc, 0444);
>  MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (num_vfs > 0)\n"
>  			   "probe_vf=port1,port2,port1+2");
>  
> -int mlx4_log_num_mgm_entry_size = MLX4_DEFAULT_MGM_LOG_ENTRY_SIZE;
> +static int mlx4_log_num_mgm_entry_size = MLX4_DEFAULT_MGM_LOG_ENTRY_SIZE;
>  module_param_named(log_num_mgm_entry_size,
>  			mlx4_log_num_mgm_entry_size, int, 0444);
>  MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> index b4f1bc5..a3f5edb 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
> @@ -231,7 +231,6 @@ do {									\
>  #define mlx4_warn(mdev, format, ...)					\
>  	dev_warn(&(mdev)->persist->pdev->dev, format, ##__VA_ARGS__)
>  
> -extern int mlx4_log_num_mgm_entry_size;

Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

>  extern int log_mtts_per_seg;
>  extern int mlx4_internal_err_reset;
>  
> -- 
> 2.7.4
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
