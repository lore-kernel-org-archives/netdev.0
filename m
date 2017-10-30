From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] net: ethernet: slicoss: remove redundant initialization
 of idx
Date: Mon, 30 Oct 2017 18:36:00 +0100
Message-ID: <3d566098-10dd-a9db-4d50-8fffebc71b92@gmx.de>
References: <20171029133809.6831-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171029133809.6831-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Colin,

On 29.10.2017 14:38, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable idx is being initialized and later on over-written by
> a new value in a do-loop without the initial value ever being
> read. Hence the initializion is redundant and can be removed.
> Cleans up clang warning:
> 
> drivers/net/ethernet/alacritech/slicoss.c:358:15: warning: Value
> stored to 'idx' during its initialization is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/alacritech/slicoss.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
> index 15a8096c60df..ac8004186fa8 100644
> --- a/drivers/net/ethernet/alacritech/slicoss.c
> +++ b/drivers/net/ethernet/alacritech/slicoss.c
> @@ -355,7 +355,7 @@ static void slic_xmit_complete(struct slic_device *sdev)
>  {
>  	struct slic_tx_queue *txq = &sdev->txq;
>  	struct net_device *dev = sdev->netdev;
> -	unsigned int idx = txq->done_idx;
> +	unsigned int idx;
>  	struct slic_tx_buffer *buff;
>  	unsigned int frames = 0;
>  	unsigned int bytes = 0;
> 

Acked-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
