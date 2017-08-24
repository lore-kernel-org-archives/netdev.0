From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH] net/mlx4_core: make mlx4_profile const
Date: Thu, 24 Aug 2017 12:04:32 +0300
Message-ID: <ac5b8b4a-edf3-604b-63c5-5ff645e0c5bc@mellanox.com>
References: <1503492459-3110-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503492459-3110-1-git-send-email-bhumirks@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 23/08/2017 3:47 PM, Bhumika Goyal wrote:
> Make these const as they are only used in a copy operation.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/main.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 541ce9e..43fb2eb 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -121,7 +121,7 @@
>   	DRV_NAME ": Mellanox ConnectX core driver v"
>   	DRV_VERSION "\n";
>   
> -static struct mlx4_profile default_profile = {
> +static const struct mlx4_profile default_profile = {
>   	.num_qp		= 1 << 18,
>   	.num_srq	= 1 << 16,
>   	.rdmarc_per_qp	= 1 << 4,
> @@ -131,7 +131,7 @@
>   	.num_mtt	= 1 << 20, /* It is really num mtt segements */
>   };
>   
> -static struct mlx4_profile low_mem_profile = {
> +static const struct mlx4_profile low_mem_profile = {
>   	.num_qp		= 1 << 17,
>   	.num_srq	= 1 << 6,
>   	.rdmarc_per_qp	= 1 << 4,
> 

Thanks Bhumika.

Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
