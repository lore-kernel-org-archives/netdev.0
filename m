From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH] net: bgmac: fix spelling mistake: "connecton" ->
 "connection"
Date: Tue, 25 Oct 2016 09:42:32 -0400
Message-ID: <20161025134231.GA30754@broadcom.com>
References: <20161024224618.10383-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34432 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934325AbcJYNmq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 09:42:46 -0400
Received: by mail-pf0-f178.google.com with SMTP id n85so3420105pfi.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 06:42:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161024224618.10383-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2016 at 11:46:18PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> trivial fix to spelling mistake in dev_err message
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

One of these days I'll learn to spell.

Acked-by: Jon Mason <jon.mason@broadcom.com>

> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 856379c..31ca204 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1449,7 +1449,7 @@ static int bgmac_phy_connect(struct bgmac *bgmac)
>  	phy_dev = phy_connect(bgmac->net_dev, bus_id, &bgmac_adjust_link,
>  			      PHY_INTERFACE_MODE_MII);
>  	if (IS_ERR(phy_dev)) {
> -		dev_err(bgmac->dev, "PHY connecton failed\n");
> +		dev_err(bgmac->dev, "PHY connection failed\n");
>  		return PTR_ERR(phy_dev);
>  	}
>  
> -- 
> 2.9.3
> 
