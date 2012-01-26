From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] stmmac: Use correct MDIO bus name so that phy_connect()
 works again
Date: Thu, 26 Jan 2012 18:22:45 +0100
Message-ID: <4F218BE5.8030407@openwrt.org>
References: <1327589210-4424-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55414 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422Ab2AZRXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 12:23:08 -0500
Received: by werb13 with SMTP id b13so579527wer.19
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 09:23:06 -0800 (PST)
In-Reply-To: <1327589210-4424-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/12 15:46, Stefan Roese wrote:
> Patch db8857bf [stmmac: use an unique MDIO bus name.] changed the
> MDIO bus name. After this phy_connect() fails. This patch changes
> the bus name in stmmac_mdio.c so that the name matching works
> again.

Alessandro already proposed such a patch: 
http://patchwork.ozlabs.org/patch/137531/
which has been applied by David already.

>
> Signed-off-by: Stefan Roese<sr@denx.de>
> Cc: Florian Fainelli<florian@openwrt.org>
> Cc: Giuseppe Cavallaro<peppe.cavallaro@st.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index da4a104..7319532 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -154,7 +154,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>   	else
>   		irqlist = priv->mii_irq;
>
> -	new_bus->name = "STMMAC MII Bus";
> +	new_bus->name = "stmmac";
>   	new_bus->read =&stmmac_mdio_read;
>   	new_bus->write =&stmmac_mdio_write;
>   	new_bus->reset =&stmmac_mdio_reset;
