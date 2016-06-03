From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: remove unused priv lock
Date: Fri, 3 Jun 2016 19:47:55 +0300
Message-ID: <5751B4BB.5060005@ti.com>
References: <1464907028-19622-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<mugunthanvnm@ti.com>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464907028-19622-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2016 01:37 AM, Ivan Khoronzhuk wrote:
> There is no reason in this lock. At least for now.
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>
> Based on master
>
>   drivers/net/ethernet/ti/cpsw.c | 3 ---
>   1 file changed, 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 9919cb3..8d1d373 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -365,7 +365,6 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
>   }
>
>   struct cpsw_priv {
> -	spinlock_t			lock;
>   	struct platform_device		*pdev;
>   	struct net_device		*ndev;
>   	struct napi_struct		napi_rx;
> @@ -2413,7 +2412,6 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
>   	}
>
>   	priv_sl2 = netdev_priv(ndev);
> -	spin_lock_init(&priv_sl2->lock);
>   	priv_sl2->data = *data;
>   	priv_sl2->pdev = pdev;
>   	priv_sl2->ndev = ndev;
> @@ -2533,7 +2531,6 @@ static int cpsw_probe(struct platform_device *pdev)
>
>   	platform_set_drvdata(pdev, ndev);
>   	priv = netdev_priv(ndev);
> -	spin_lock_init(&priv->lock);
>   	priv->pdev = pdev;
>   	priv->ndev = ndev;
>   	priv->dev  = &ndev->dev;
>

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

-- 
regards,
-grygorii
