From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 01/75] netx: declare MODULE_FIRMWARE
Date: Tue, 10 Nov 2009 08:36:08 +0100
Message-ID: <20091110073608.GR30179@pengutronix.de>
References: <1257629856.15927.370.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:58966 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbZKJHgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 02:36:05 -0500
Content-Disposition: inline
In-Reply-To: <1257629856.15927.370.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 07, 2009 at 09:37:36PM +0000, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> Note that the filenames are generated in xc_request_firmware(), defined
> in arch/arm/mach-netx/xc.c.  I'm not sure whether it's actually worth
> doing this for a platform driver.

Acked-by: Sascha Hauer <s.hauer@pengutronix.de>

> 
> Ben.
> 
>  drivers/net/netx-eth.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
> index 9f42354..a0d65f5 100644
> --- a/drivers/net/netx-eth.c
> +++ b/drivers/net/netx-eth.c
> @@ -510,3 +510,6 @@ module_exit(netx_eth_cleanup);
>  MODULE_AUTHOR("Sascha Hauer, Pengutronix");
>  MODULE_LICENSE("GPL");
>  MODULE_ALIAS("platform:" CARDNAME);
> +MODULE_FIRMWARE("xc0.bin");
> +MODULE_FIRMWARE("xc1.bin");
> +MODULE_FIRMWARE("xc2.bin");
> -- 
> 1.6.5.2
> 
> 
> 
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
