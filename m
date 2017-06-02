From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next] net: phy: smsc: Implement PHY statistics
Date: Fri, 2 Jun 2017 23:35:07 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA9CB9@CHN-SV-EXMX02.mchp-main.com>
References: <1496438670-30829-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <vivien.didelot@savoirfairelinux.com>, <cphealy@gmail.com>,
        <nikita.yoush@cogentembedded.com>, <netdev@vger.kernel.org>
To: <andrew@lunn.ch>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:31715 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBXfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 19:35:09 -0400
In-Reply-To: <1496438670-30829-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

>  static int smsc_phy_probe(struct phy_device *phydev)
>  {
>  	struct device *dev = &phydev->mdio.dev;
> @@ -206,6 +258,11 @@ static struct phy_driver smsc_phy_driver[] = {
>  	.ack_interrupt	= smsc_phy_ack_interrupt,
>  	.config_intr	= smsc_phy_config_intr,
> 
> +	/* Statistics */
> +	.get_sset_count = smsc_get_sset_count,
> +	.get_strings = smsc_get_strings,
> +	.get_stats = smsc_get_stats,
> +
...
> 
> +	/* Statistics */
> +	.get_sset_count = smsc_get_sset_count,
> +	.get_strings = smsc_get_strings,
> +	.get_stats = smsc_get_stats,
> +
...
> +	/* Statistics */
> +	.get_sset_count = smsc_get_sset_count,
> +	.get_strings = smsc_get_strings,
> +	.get_stats = smsc_get_stats,
> +
...
> +	/* Statistics */
> +	.get_sset_count = smsc_get_sset_count,
> +	.get_strings = smsc_get_strings,
> +	.get_stats = smsc_get_stats,
> +
Just cosmetic thing.
How about aligning with other members in structure like
> +	.get_sset_count = smsc_get_sset_count,
> +	.get_strings     = smsc_get_strings,
> +	.get_stats        = smsc_get_stats,

Reviewed-By: Woojung Huh <Woojung.Huh@microchip.com>
