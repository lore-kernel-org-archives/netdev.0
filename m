From: Kumar Gaurav <kumargauravgupta3@gmail.com>
Subject: Re: [PATCH 17/17] net:ethernet:lantiq_etop.c: Removed deprecated
 IRQF_DISABLED
Date: Sat, 10 Aug 2013 00:01:30 +0530
Message-ID: <52053582.6050207@gmail.com>
References: <1376072759-11814-1-git-send-email-kumargauravgupta3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, gregkh@linuxfoundation.org,
	yongjun_wei@trendmicro.com.cn, konszert@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Kumar Gaurav <kumargauravgupta3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376072759-11814-1-git-send-email-kumargauravgupta3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's a single patch. Please don't be confused with the subject [PATCH 
17/17]. I forgot to edit this before sending.
my apology for mistake

On Friday 09 August 2013 11:55 PM, Kumar Gaurav wrote:
> Removed IRQF_DISABLED as it is deprecated and fixed a coding style issue
> of more than 80 chars on single line by sliting the line in two.
>
> Signed-off-by: Kumar Gaurav <kumargauravgupta3@gmail.com>
> ---
>   drivers/net/ethernet/lantiq_etop.c |    8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
> index bfdb0686..04c3a82 100644
> --- a/drivers/net/ethernet/lantiq_etop.c
> +++ b/drivers/net/ethernet/lantiq_etop.c
> @@ -282,7 +282,7 @@ ltq_etop_hw_init(struct net_device *dev)
>   
>   		if (IS_TX(i)) {
>   			ltq_dma_alloc_tx(&ch->dma);
> -			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
> +			request_irq(irq, ltq_etop_dma_irq, 0,
>   				"etop_tx", priv);
>   		} else if (IS_RX(i)) {
>   			ltq_dma_alloc_rx(&ch->dma);
> @@ -291,7 +291,7 @@ ltq_etop_hw_init(struct net_device *dev)
>   				if (ltq_etop_alloc_skb(ch))
>   					return -ENOMEM;
>   			ch->dma.desc = 0;
> -			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
> +			request_irq(irq, ltq_etop_dma_irq, 0,
>   				"etop_rx", priv);
>   		}
>   		ch->dma.irq = irq;
> @@ -653,7 +653,9 @@ ltq_etop_init(struct net_device *dev)
>   	if (err)
>   		goto err_netdev;
>   
> -	/* Set addr_assign_type here, ltq_etop_set_mac_address would reset it. */
> +	/* Set addr_assign_type here,
> +	 *ltq_etop_set_mac_address would reset it.
> +	 */
>   	if (random_mac)
>   		dev->addr_assign_type = NET_ADDR_RANDOM;
>   
