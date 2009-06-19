From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] TI DaVinci EMAC : Fix rmmod error
Date: Fri, 19 Jun 2009 13:54:12 -0700
Message-ID: <87hbyct05n.fsf@deeprootsystems.com>
References: <1245238134-23512-1-git-send-email-chaithrika@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Chaithrika U S <chaithrika@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:14398 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbZFSUyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 16:54:12 -0400
Received: by wf-out-1314.google.com with SMTP id 26so946903wfd.4
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 13:54:15 -0700 (PDT)
In-Reply-To: <1245238134-23512-1-git-send-email-chaithrika@ti.com> (Chaithrika U. S.'s message of "Wed\, 17 Jun 2009 07\:28\:54 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chaithrika U S <chaithrika@ti.com> writes:

> clk_disable was called twice in the remove function.
> Correct this so that the driver module unloads without error.
>
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>

Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
(TI DaVinci arch maintainer)

Will pull into DaVinci git until it merges upstream.

Kevin

> ---
> Applies to Linus' kernel tree
>
>  drivers/net/davinci_emac.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 0e9b9f9..2df8fb0 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -2767,7 +2767,6 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
>  
>  	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
>  
> -	clk_disable(emac_clk);
>  	platform_set_drvdata(pdev, NULL);
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	mdiobus_unregister(priv->mii_bus);
> -- 
> 1.5.6
>
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
