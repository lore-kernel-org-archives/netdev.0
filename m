From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/5] sfc: Implement message level control
Date: Wed, 23 Jun 2010 18:29:20 -0700 (PDT)
Message-ID: <20100623.182920.28799851.davem@davemloft.net>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
	<1277328607.2101.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754128Ab0FXB3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 21:29:10 -0400
In-Reply-To: <1277328607.2101.9.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 23 Jun 2010 22:30:07 +0100

> @@ -850,6 +866,8 @@ const struct ethtool_ops efx_ethtool_ops = {
>  	.get_drvinfo		= efx_ethtool_get_drvinfo,
>  	.get_regs_len		= efx_ethtool_get_regs_len,
>  	.get_regs		= efx_ethtool_get_regs,
> +	.get_msglevel		= efx_ethtool_get_msglevel,
> +	.set_msglevel		= efx_ethtool_set_msglevel,
>  	.nway_reset		= efx_ethtool_nway_reset,
>  	.get_link		= efx_ethtool_get_link,
>  	.get_eeprom_len		= efx_ethtool_get_eeprom_len,

davem@sunset:~/src/GIT/net-next-2.6$ egrep get_regs_len drivers/net/sfc/ethtool.c
davem@sunset:~/src/GIT/net-next-2.6$ 

I don't know what tree you're patching this against, but neither net-2.6 nor
net-next-2.6 have the context you have here in your patch so these patches
do not apply at all.
