From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 2/5] Add KSZ8795 switch driver support in Makefile
Date: Thu, 7 Sep 2017 22:29:34 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121B0A@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A80@CHN-SV-EXMX02.mchp-main.com>
 <20170907215551.GV11248@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170907215551.GV11248@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, September 07, 2017 2:56 PM
> To: Tristram Ha - C24268
> Cc: muvarov@gmail.com; pavel@ucw.cz; nathan.leigh.conrad@gmail.com;
> vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh - C21699
> Subject: Re: [PATCH RFC 2/5] Add KSZ8795 switch driver support in Makefile
> 
> On Thu, Sep 07, 2017 at 09:17:10PM +0000, Tristram.Ha@microchip.com wrote:
> > From: Tristram Ha <Tristram.Ha@microchip.com>
> >
> > Add KSZ8795 switch support with SPI access.
> >
> > Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> > ---
> > diff --git a/drivers/net/dsa/microchip/Makefile
> b/drivers/net/dsa/microchip/Makefile
> > index 0961c30..0d8ba48 100644
> > --- a/drivers/net/dsa/microchip/Makefile
> > +++ b/drivers/net/dsa/microchip/Makefile
> > @@ -1,2 +1,4 @@
> >  obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz9477.o ksz_common.o
> >  obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o
> > +obj-$(CONFIG_MICROCHIP_KSZ8795)	        += ksz8795.o ksz_common.o
> > +obj-$(CONFIG_MICROCHIP_KSZ8795_SPI_DRIVER)	+= ksz8795_spi.o
> 
> I've not tried it, but i think this breaks the build
> 
>      Andrew

So you would like to have all 5 patches in 1 patch file?
