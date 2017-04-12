From: <Woojung.Huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Subject: RE: [PATCH v3] smsc95xx: Add comments to the registers definition
Date: Wed, 12 Apr 2017 22:10:06 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A421E3@CHN-SV-EXMX02.mchp-main.com>
References: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
 <20170410135251.GC19820@lunn.ch>
 <20170411.221836.113758478587841074.davem@davemloft.net>
 <20170412092405.doyczwsqnzkizarz@SMX-2>
 <9235D6609DB808459E95D78E17F2E43D40A41DA1@CHN-SV-EXMX02.mchp-main.com>
 <20170412160123.zhzg67m4rpzcsmap@SMX-2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>, <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <martin-ufNpD2TjPakDzzZUHZsW5w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412160123.zhzg67m4rpzcsmap@SMX-2>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I based my comments on the datasheet. For the LED_GPIO_CFG register, the
> datasheet says:
> > This register configures the external GPIO[2:0] pins.
> 
> QFN package description also indicates GPIOs 0, 1 & 2.
> As an example for the LAN9514, pin 22 of the QFN indicates:
> > nSPD_LED/GPIO2
> 
> In LED_GPIO_CFG register, GPCTL2 description indicates:
> > The value of this field determines the function of the external GPIO2
> > pin as follows
> 
> Do you confirm it's actually GPIO 10, 9 and 8?
> I think I may have misunderstood something.
Sorry forgetting that you are referring RPi which uses LAN9514.
Because these LEDs' GPIO can vary per chip (LAN9500, 9514..), it would be better
not putting GPIO number. LAN9500 are GPIO 10/9/8 as described.

> While we are here, could you indicate the meaning of the bit 2 of
> HW_CFG register (it's named HW_CFG_PSEL_)? It's the only bit I didn't
> succeed to comment because I didn't find it in the datasheet.
> I will then add it to the patch!
It indicates internal & external phy, PSEL means PHY Select.
You can find at LAN9500 doc in http://ww1.microchip.com/downloads/en/DeviceDoc/00001875C.pdf.

> I'm also wondering what the meaning of STRAP_STATUS is. I could also
> comment it if you or Steve can provide the information.
It is marked as reserved in above LAN9500 manual.
You may guess from configuration straps in the manual and define names.

Woojung
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
