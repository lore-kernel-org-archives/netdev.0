From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH][net-next] net: qualcomm: rmnet: remove unused variable
 priv
Date: Thu, 31 Aug 2017 14:34:20 -0600
Message-ID: <a3a3328009e7c0ca8d910e1b15ad0b2a@codeaurora.org>
References: <20170831140727.28170-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170831140727.28170-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-08-31 08:07, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> priv is being assigned but is never used, so remove it.
> 
> Cleans up clang build warning:
> "warning: Value stored to 'priv' is never read"
> 
> Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial
> implementation")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
> b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
> index c8b573d28dcf..bf7455fdafcc 100644
> --- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
> +++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
> @@ -73,9 +73,6 @@ static const struct net_device_ops rmnet_vnd_ops = {
>   */
>  void rmnet_vnd_setup(struct net_device *rmnet_dev)
>  {
> -	struct rmnet_priv *priv;
> -
> -	priv = netdev_priv(rmnet_dev);
>  	netdev_dbg(rmnet_dev, "Setting up device %s\n", rmnet_dev->name);
> 
>  	rmnet_dev->netdev_ops = &rmnet_vnd_ops;

Thanks for fixing this.

Acked-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
