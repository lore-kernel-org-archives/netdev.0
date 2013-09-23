From: Matthew Whitehead <tedheadster@gmail.com>
Subject: Re: [net-next] hp100: replace hardcoded name in /proc/interrupts
 with interface name
Date: Sun, 22 Sep 2013 22:26:22 -0400
Message-ID: <20130923022621.GB17124@gmail.com>
References: <1379789289-10961-1-git-send-email-me@mihirsingh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mihir Singh <me@mihirsingh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:57856 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051Ab3IWC00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 22:26:26 -0400
Received: by mail-qe0-f41.google.com with SMTP id 1so1745884qee.14
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 19:26:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1379789289-10961-1-git-send-email-me@mihirsingh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 06:48:09PM +0000, Mihir Singh wrote:
> The /proc/interrupts file displays hp100, which is not the accepted style. Printing eth%d is more helpful.
> 
> Signed-off-by: Mihir Singh <me@mihirsingh.com>
> ---
>  drivers/net/ethernet/hp/hp100.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
> index 91227d0..3786009 100644
> --- a/drivers/net/ethernet/hp/hp100.c
> +++ b/drivers/net/ethernet/hp/hp100.c
> @@ -1098,7 +1098,7 @@ static int hp100_open(struct net_device *dev)
>  	if (request_irq(dev->irq, hp100_interrupt,
>  			lp->bus == HP100_BUS_PCI || lp->bus ==
>  			HP100_BUS_EISA ? IRQF_SHARED : 0,
> -			"hp100", dev)) {
> +			dev->name, dev)) {
>  		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
>  		return -EAGAIN;
>  	}
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Reviewed-By: Matthew Whitehead <tedheadster@gmail.com>
