From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH] net/mlx5e: Remove unused variable
Date: Thu, 19 Jan 2017 11:44:23 +0200
Message-ID: <edfd4148-05b6-24f7-702e-03cd3e7817f0@mellanox.com>
References: <20170119093401.2582672-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Gal Pressman <galp@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119093401.2582672-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 19/01/2017 11:33 AM, Arnd Bergmann wrote:
> A cleanup removed the only user of this variable
>
> mlx5/core/en_ethtool.c: In function 'mlx5e_set_channels':
> mlx5/core/en_ethtool.c:546:6: error: unused variable 'ncv' [-Werror=unused-variable]
>
> Let's remove the declaration as well.
>
> Fixes: 639e9e94160e ("net/mlx5e: Remove unnecessary checks when setting num channels")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>   drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> index b1b9eb6ee135..5197817e4b2f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> @@ -543,7 +543,6 @@ static int mlx5e_set_channels(struct net_device *dev,
>   			      struct ethtool_channels *ch)
>   {
>   	struct mlx5e_priv *priv = netdev_priv(dev);
> -	int ncv = mlx5e_get_max_num_channels(priv->mdev);
>   	unsigned int count = ch->combined_count;
>   	bool arfs_enabled;
>   	bool was_opened;
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Thanks for the fix!

Regards,
Tariq
