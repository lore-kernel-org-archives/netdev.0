From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 v2] net: add micrel KSZ8873MLL switch support
Date: Wed, 21 Nov 2012 11:03:56 -0800
Message-ID: <1353524636.24807.28.camel@joe-AO722>
References: <1353493630-30867-1-git-send-email-plagnioj@jcrosoft.com>
	 <1353512287-24048-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59860 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755566Ab2KUTD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 14:03:57 -0500
In-Reply-To: <1353512287-24048-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 16:38 +0100, Jean-Christophe PLAGNIOL-VILLARD
wrote:
> this will allow to detect the link between the switch and the soc
[]
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
[]
> @@ -127,6 +127,39 @@ static int ks8051_config_init(struct phy_device *phydev)
[]
> +int ksz8873mll_read_status(struct phy_device *phydev)
> +{
[]
> +	regval = phy_read(phydev, KSZ8873MLL_GLOBAL_CONTROL_4);
> +
> +	if (regval & KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX)
> +		phydev->duplex = DUPLEX_HALF;
> +	else
> +		phydev->duplex = DUPLEX_FULL;

This doesn't check for phy_read errors.
Shouldn't it?
