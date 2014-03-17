From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: phy: bcm7xxx: fix spurious MDIO
 failures during workaround
Date: Mon, 17 Mar 2014 16:04:36 -0400 (EDT)
Message-ID: <20140317.160436.1560449781844166790.davem@davemloft.net>
References: <1394838545-7746-1-git-send-email-f.fainelli@gmail.com>
	<1394838545-7746-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaCQUEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 16:04:38 -0400
In-Reply-To: <1394838545-7746-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 14 Mar 2014 16:09:04 -0700

> @@ -87,21 +87,6 @@ static void phy_write_misc(struct phy_device *phydev,
>  
>  static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
>  {
> -	/* write AFE_RXCONFIG_0 */
> -	phy_write_misc(phydev, 0x38, 0x0000, 0xeb19);
> -
> -	/* write AFE_RXCONFIG_1 */
> -	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
> -
> -	/* write AFE_RX_LP_COUNTER */
> -	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
> -
> -	/* write AFE_HPF_TRIM_OTHERS */
> -	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
> -
> -	/* write AFTE_TX_CONFIG */
> -	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);
> -
 ...
> +	/* write AFE_RXCONFIG_0 */
> +	phy_write_misc(phydev, 0x38, 0x0000, 0xeb19);
> +
> +	/* write AFE_RXCONFIG_1 */
> +	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
> +
> +	/* write AFE_RX_LP_COUNTER */
> +	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
> +
> +	/* write AFE_HPF_TRIM_OTHERS */
> +	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
> +
> +	/* write AFTE_TX_CONFIG */
> +	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);
> +
> +
>  	return 0;
>  }
>  

If you can use mnenomics in the _comment_ you can certainly do so in
the code too.

I want defines added for the address and content of these registers.

Thanks.
