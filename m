From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/mlx4: fix spelling mistake: "coalesing" ->
 "coalescing"
Date: Mon, 26 Jun 2017 17:41:06 +0300
Message-ID: <65224576-2bed-7f14-6aa5-0561094b62ee@mellanox.com>
References: <20170626125346.22143-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170626125346.22143-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 26/06/2017 3:53 PM, Colin King wrote:
> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> Trivial fix to spelling mistake in en_dbg debug message
> 
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 18252a79a074..9da76e3be2fc 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1352,7 +1352,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
>   	priv->rx_usecs = MLX4_EN_RX_COAL_TIME;
>   	priv->tx_frames = MLX4_EN_TX_COAL_PKTS;
>   	priv->tx_usecs = MLX4_EN_TX_COAL_TIME;
> -	en_dbg(INTR, priv, "Default coalesing params for mtu:%d - rx_frames:%d rx_usecs:%d\n",
> +	en_dbg(INTR, priv, "Default coalescing params for mtu:%d - rx_frames:%d rx_usecs:%d\n",
>   	       priv->dev->mtu, priv->rx_frames, priv->rx_usecs);
>   
>   	/* Setup cq moderation params */
> 
Acked-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Thanks Colin.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
