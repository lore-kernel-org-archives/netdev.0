From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] SET_NETDEV_DEV() in fec_mpc52xx.c
Date: Sat, 01 Dec 2007 16:35:57 -0500
Message-ID: <4751D3BD.6020106@pobox.com>
References: <1196273071.30806.46.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Domen Puncer <domen.puncer@telargo.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32926 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763AbXLAVgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:36:08 -0500
In-Reply-To: <1196273071.30806.46.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> This helps to allow the Fedora installer to use the built-in Ethernet on
> the Efika for a network install.
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -971,6 +971,8 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
>  
>  	mpc52xx_fec_reset_stats(ndev);
>  
> +	SET_NETDEV_DEV(ndev, &op->dev);
> +
>  	/* Register the new network device */
>  	rv = register_netdev(ndev);

applied


