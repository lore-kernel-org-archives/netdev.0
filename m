From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v4 net-next] lan78xx: Use irq_domain for phy interrupt
 from USB Int. EP
Date: Wed, 2 Nov 2016 19:31:39 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4095E0DA@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D4095D3D8@CHN-SV-EXMX02.mchp-main.com>
 <20161102.152441.459205528111412700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:49856 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753245AbcKBTbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:31:41 -0400
In-Reply-To: <20161102.152441.459205528111412700.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, November 02, 2016 3:25 PM
> To: Woojung Huh - C21699
> Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; andrew@lunn.ch;
> UNGLinuxDriver
> Subject: Re: [PATCH v4 net-next] lan78xx: Use irq_domain for phy interrupt
> from USB Int. EP
> 
> From: <Woojung.Huh@microchip.com>
> Date: Tue, 1 Nov 2016 20:02:00 +0000
> 
> > From: Woojung Huh <woojung.huh@microchip.com>
> >
> > To utilize phylib with interrupt fully than handling some of phy stuff in the
> MAC driver,
> > create irq_domain for USB interrupt EP of phy interrupt and
> > pass the irq number to phy_connect_direct() instead of
> PHY_IGNORE_INTERRUPT.
> >
> > Idea comes from drivers/gpio/gpio-dl2.c
> >
> > Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> 
> Applied.

Thanks!
