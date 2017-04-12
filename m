From: martin@wetterwald.eu
Subject: Re: [PATCH v3] smsc95xx: Add comments to the registers definition
Date: Wed, 12 Apr 2017 18:01:23 +0200
Message-ID: <20170412160123.zhzg67m4rpzcsmap@SMX-2>
References: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
 <20170410135251.GC19820@lunn.ch>
 <20170411.221836.113758478587841074.davem@davemloft.net>
 <20170412092405.doyczwsqnzkizarz@SMX-2>
 <9235D6609DB808459E95D78E17F2E43D40A41DA1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch, steve.glendinning@shawell.net,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcorrecteurs.net ([94.23.204.81]:42185 "EHLO zcorrecteurs.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752888AbdDLQCD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 12:02:03 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A41DA1@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/17 14:25, Woojung.Huh@microchip.com wrote:
> > +/* LED General Purpose IO Configuration Register */
> > +#define LED_GPIO_CFG		(0x24)
> > +#define LED_GPIO_CFG_SPD_LED	(0x01000000)	/* GPIO2 as SPD LED
> > */
> > +#define LED_GPIO_CFG_LNK_LED	(0x00100000)	/* GPIO1 as LNK LED
> > */
> > +#define LED_GPIO_CFG_FDX_LED	(0x00010000)	/* GPIO0 as FDX LED
> > */
> Because comments are one of main reason for this patch.
> It is GPIO 10, 9 & 8.
> 
> Woojung

Hello Woojung,

I based my comments on the datasheet. For the LED_GPIO_CFG register, the
datasheet says:
> This register configures the external GPIO[2:0] pins.

QFN package description also indicates GPIOs 0, 1 & 2.
As an example for the LAN9514, pin 22 of the QFN indicates:
> nSPD_LED/GPIO2

In LED_GPIO_CFG register, GPCTL2 description indicates:
> The value of this field determines the function of the external GPIO2
> pin as follows

Do you confirm it's actually GPIO 10, 9 and 8?
I think I may have misunderstood something.


While we are here, could you indicate the meaning of the bit 2 of
HW_CFG register (it's named HW_CFG_PSEL_)? It's the only bit I didn't
succeed to comment because I didn't find it in the datasheet.
I will then add it to the patch!

I'm also wondering what the meaning of STRAP_STATUS is. I could also
comment it if you or Steve can provide the information.


Thank you!

Martin
