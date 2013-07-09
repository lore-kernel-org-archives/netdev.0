From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/cadence/macb: fix bug/typo in extracting gem_irq_read_clear
 bit
Date: Tue, 9 Jul 2013 18:02:23 +0200
Message-ID: <51DC340F.2060402@atmel.com>
References: <1373358960-10900-1-git-send-email-neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>
To: Jongsung Kim <neidhard.kim@lge.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1373358960-10900-1-git-send-email-neidhard.kim@lge.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2013 10:36, Jongsung Kim :
> Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: stable <stable@vger.kernel.org> # 3.10+

Thanks for having spotted that.

Best regards,

> ---
>   drivers/net/ethernet/cadence/macb.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index c89aa41..b4e0dc8 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1070,7 +1070,7 @@ static void macb_configure_dma(struct macb *bp)
>   static void macb_configure_caps(struct macb *bp)
>   {
>   	if (macb_is_gem(bp)) {
> -		if (GEM_BF(IRQCOR, gem_readl(bp, DCFG1)) == 0)
> +		if (GEM_BFEXT(IRQCOR, gem_readl(bp, DCFG1)) == 0)
>   			bp->caps |= MACB_CAPS_ISR_CLEAR_ON_WRITE;
>   	}
>   }
>


-- 
Nicolas Ferre
