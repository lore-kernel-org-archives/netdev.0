From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] sis900 printk audit
Date: Sat, 22 Jan 2005 23:26:40 +0100
Message-ID: <20050122222640.GB24461@electric-eye.fr.zoreil.com>
References: <20050122214657.18649.66345@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
Content-Disposition: inline
In-Reply-To: <20050122214657.18649.66345@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano <webvenza@libero.it> :
[...]
> Index: sis900.c
> ===================================================================
> --- a/drivers/net/sis900.c	(revision 83)
> +++ b/drivers/net/sis900.c	(revision 84)
[...]
> @@ -1906,8 +1918,22 @@
>  	strcpy (info->bus_info, pci_name(sis_priv->pci_dev));
>  }
>  
> +static u32 sis900_get_msglevel(struct net_device *net_dev)
> +{
> +	struct sis900_private *sis_priv = net_dev->priv;

s/net_dev->priv/netdev_priv/

--
Ueimor
