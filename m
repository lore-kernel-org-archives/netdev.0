From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 3/4] lan78xx: Fix for eeprom read/write when device
 autosuspend
Date: Wed, 6 Sep 2017 16:06:05 +0200
Message-ID: <20170906140605.GD11864@lunn.ch>
References: <CE371C1263339941885964188A0225FA333391@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58702 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932158AbdIFOGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:06:08 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA333391@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nisar

> +	else if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
> +		 (ee->offset >= 0 && ee->offset < MAX_EEPROM_SIZE) &&
> +		 (ee->len > 0 && (ee->offset + ee->len) <= MAX_EEPROM_SIZE))
> +		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);

This change does not appear to have anything to do with auto suspend.
Please make it a separate patch.

       Andrew
