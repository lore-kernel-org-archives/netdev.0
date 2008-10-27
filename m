From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ibm_newemac: Fix typo in flow control config option
Date: Mon, 27 Oct 2008 14:52:42 -0400
Message-ID: <49060DFA.7090901@garzik.org>
References: <20081024135314.GA2299@yoda.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, hch@lst.de, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53102 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbYJ0Swv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:52:51 -0400
In-Reply-To: <20081024135314.GA2299@yoda.jdub.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> The recent build fix for ibm_newemac has a typo in the config
> option #ifdef used for disabling flow control.  This corrects
> it to the proper Kconfig option name.
> 
> Reported-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> 
> ---
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index 2ee2622..901212a 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -2605,7 +2605,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
>  		    of_device_is_compatible(np, "ibm,emac-440gr"))
>  			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
>  		if (of_device_is_compatible(np, "ibm,emac-405ez")) {
> -#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CONTROL
> +#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL
>  			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
>  #else
>  			printk(KERN_ERR "%s: Flow control not disabled!\n",

applied


