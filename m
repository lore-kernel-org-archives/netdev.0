From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: compile fix re netif_rx signature changes
Date: Mon, 29 Dec 2008 16:43:41 +0000
Message-ID: <OF7ED135E6.60E49762-ON8025752E.005BAA36-8025752E.005BFFA9@smsc.com>
References: <20081229115706.GA21117@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3729 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751591AbYL2QpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 11:45:11 -0500
In-Reply-To: <20081229115706.GA21117@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Alexey.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/smsc911x.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -1484,13 +1484,13 @@ static irqreturn_t smsc911x_irqhandler(int 
> irq, void *dev_id)
>     }
> 
>     if (likely(intsts & inten & INT_STS_RSFL_)) {
> -      if (likely(netif_rx_schedule_prep(dev, &pdata->napi))) {
> +      if (likely(netif_rx_schedule_prep(&pdata->napi))) {
>           /* Disable Rx interrupts */
>           temp = smsc911x_reg_read(pdata, INT_EN);
>           temp &= (~INT_EN_RSFL_EN_);
>           smsc911x_reg_write(pdata, INT_EN, temp);
>           /* Schedule a NAPI poll */
> -         __netif_rx_schedule(dev, &pdata->napi);
> +         __netif_rx_schedule(&pdata->napi);
>        } else {
>           SMSC_WARNING(RX_ERR,
>              "netif_rx_schedule_prep failed");
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

