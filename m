From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: lpc_eth: Remove unused variables
Date: Fri, 8 Jan 2016 16:58:32 +0100
Message-ID: <20160108155832.GH4389@lunn.ch>
References: <1452255556-21827-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44097 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406AbcAHP6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 10:58:33 -0500
Content-Disposition: inline
In-Reply-To: <1452255556-21827-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2016 at 10:19:16AM -0200, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> introduced the following build warnings:
> 
> drivers/net/ethernet/nxp/lpc_eth.c: In function 'lpc_mii_init':
> drivers/net/ethernet/nxp/lpc_eth.c:865:1: warning: label 'err_out_1' defined but not used [-Wunused-label]
> drivers/net/ethernet/nxp/lpc_eth.c:826:20: warning: unused variable 'i' [-Wunused-variable]
> 
> Remove the unused variables to fix them.
> 
> Reported-by: Olof's autobuilder <build@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Acked-by: Andrew Lunn <andrew@lunn.ch>

	  Andrew

> ---
>  drivers/net/ethernet/nxp/lpc_eth.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
> index a9ce37f..b1ce7aa 100644
> --- a/drivers/net/ethernet/nxp/lpc_eth.c
> +++ b/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -823,7 +823,7 @@ static int lpc_mii_probe(struct net_device *ndev)
>  
>  static int lpc_mii_init(struct netdata_local *pldat)
>  {
> -	int err = -ENXIO, i;
> +	int err = -ENXIO;
>  
>  	pldat->mii_bus = mdiobus_alloc();
>  	if (!pldat->mii_bus) {
> @@ -862,7 +862,6 @@ static int lpc_mii_init(struct netdata_local *pldat)
>  
>  err_out_unregister_bus:
>  	mdiobus_unregister(pldat->mii_bus);
> -err_out_1:
>  	mdiobus_free(pldat->mii_bus);
>  err_out:
>  	return err;
> -- 
> 1.9.1
> 
