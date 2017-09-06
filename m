From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH net 3/4] lan78xx: Fix for eeprom read/write when device
 autosuspend
Date: Wed, 6 Sep 2017 17:34:58 +0000
Message-ID: <CE371C1263339941885964188A0225FA3335D6@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA333391@CHN-SV-EXMX03.mchp-main.com>
 <20170906140605.GD11864@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:31678 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdIFRfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 13:35:45 -0400
In-Reply-To: <20170906140605.GD11864@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, will make separate patch.

> Hi Nisar
> 
> > +	else if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
> > +		 (ee->offset >= 0 && ee->offset < MAX_EEPROM_SIZE) &&
> > +		 (ee->len > 0 && (ee->offset + ee->len) <=
> MAX_EEPROM_SIZE))
> > +		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len,
> data);
> 
> This change does not appear to have anything to do with auto suspend.
> Please make it a separate patch.
> 
>        Andrew
