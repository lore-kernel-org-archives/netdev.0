From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/12] orinoco: Symbol 3.0x firmware needs broken_disableport
Date: Mon, 16 May 2005 11:04:48 +1000
Message-ID: <20050516010448.GD6053@localhost.localdomain>
References: <20050514153010.GD3643@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, proski@gnu.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20050514153010.GD3643@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 14, 2005 at 05:30:10PM +0200, Christoph Hellwig wrote:
> Patch from Pavel Roskin.

Acked-by: David Gibson <hermes@gibson.dropbear.id.au>

> Index: linux-2.6/drivers/net/wireless/orinoco.c
> ===================================================================
> +++ linux-2.6/drivers/net/wireless/orinoco.c	2005-05-14 16:57:39.000000000 +0200
> @@ -2223,6 +2223,8 @@
>  			       firmver >= 0x31000;
>  		priv->has_preamble = (firmver >= 0x20000);
>  		priv->ibss_port = 4;
> + 		priv->broken_disableport = (firmver == 0x25013) ||
> + 					   (firmver >= 0x30000 && firmver <= 0x31000);
>  		/* Tested with Intel firmware : 0x20015 => Jean II */
>  		/* Tested with 3Com firmware : 0x15012 & 0x22001 => Jean II */
>  		break;
> 

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
