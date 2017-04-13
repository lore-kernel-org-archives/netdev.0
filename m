From: martin@wetterwald.eu
Subject: Re: [PATCH v3] smsc95xx: Add comments to the registers definition
Date: Thu, 13 Apr 2017 10:10:27 +0200
Message-ID: <20170413081027.bmt447cwz7jlltwk@SMX-2>
References: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
 <20170410135251.GC19820@lunn.ch>
 <20170411.221836.113758478587841074.davem@davemloft.net>
 <20170412092405.doyczwsqnzkizarz@SMX-2>
 <9235D6609DB808459E95D78E17F2E43D40A41DA1@CHN-SV-EXMX02.mchp-main.com>
 <20170412160123.zhzg67m4rpzcsmap@SMX-2>
 <9235D6609DB808459E95D78E17F2E43D40A421E3@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch, steve.glendinning@shawell.net,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcorrecteurs.net ([94.23.204.81]:45849 "EHLO zcorrecteurs.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750745AbdDMIKz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 04:10:55 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A421E3@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/17 22:10, Woojung.Huh@microchip.com wrote:
> Sorry forgetting that you are referring RPi which uses LAN9514.
> Because these LEDs' GPIO can vary per chip (LAN9500, 9514..), it would be better
> not putting GPIO number. LAN9500 are GPIO 10/9/8 as described.
> 
> > While we are here, could you indicate the meaning of the bit 2 of
> > HW_CFG register (it's named HW_CFG_PSEL_)? It's the only bit I didn't
> > succeed to comment because I didn't find it in the datasheet.
> > I will then add it to the patch!
> It indicates internal & external phy, PSEL means PHY Select.
> You can find at LAN9500 doc in http://ww1.microchip.com/downloads/en/DeviceDoc/00001875C.pdf.
> 
> > I'm also wondering what the meaning of STRAP_STATUS is. I could also
> > comment it if you or Steve can provide the information.
> It is marked as reserved in above LAN9500 manual.
> You may guess from configuration straps in the manual and define names.
> 
> Woojung

Thank you for your help Woojung!

Martin
