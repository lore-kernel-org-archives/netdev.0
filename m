From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] smc91x: fix nowait printout
Date: Sat, 13 Sep 2008 15:12:55 -0400
Message-ID: <48CC10B7.30504@garzik.org>
References: <20080908050256.11555.34058.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.miao@marvell.com, nico@cam.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59925 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbYIMTNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:13:00 -0400
In-Reply-To: <20080908050256.11555.34058.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Magnus Damm wrote:
> From: Magnus Damm <damm@igel.co.jp>
> 
> Commit c4f0e76747e80578a8f7fddd82fd0ce8127bd2f8 added nowait platform
> data support. The printout code was however not updated, so the value
> of SMC_NOWAIT is still used. This patch makes sure that nowait is printed
> accordingly to platform data.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  drivers/net/smc91x.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- 0001/drivers/net/smc91x.c
> +++ work/drivers/net/smc91x.c	2008-09-03 18:42:56.000000000 +0900
> @@ -1961,7 +1961,8 @@ static int __init smc_probe(struct net_d
>  		if (dev->dma != (unsigned char)-1)
>  			printk(" DMA %d", dev->dma);
>  
> -		printk("%s%s\n", nowait ? " [nowait]" : "",
> +		printk("%s%s\n",
> +			lp->cfg.flags & SMC91X_NOWAIT ? " [nowait]" : "",
>  			THROTTLE_TX_PKTS ? " [throttle_tx]" : "");

applied


