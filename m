From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] More ethtool support for sis900 (with locking)
Date: Sat, 5 Mar 2005 22:28:38 +0100
Message-ID: <20050305212838.GD25116@electric-eye.fr.zoreil.com>
References: <20050305210745.6763.6618@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Daniele Venzano <webvenza@libero.it>
Content-Disposition: inline
In-Reply-To: <20050305210745.6763.6618@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano <webvenza@libero.it> :
[...]
> Index: sis900.c
> ===================================================================
> --- a/drivers/net/sis900.c	(revision 95)
> +++ b/drivers/net/sis900.c	(revision 98)
[...]
> @@ -1943,10 +1952,47 @@
>  	sis_priv->msg_enable = value;
>  }
>  
> +static u32 sis900_get_link(struct net_device *net_dev)
> +{
> +	struct sis900_private *sis_priv = net_dev->priv;

Any reason to not use netdev_priv() ?

I would not mind an empty line between the declaration of variables
and the actual code.

--
Ueimor
