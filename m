From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/6] The file ksz_common.c will be used by other KSZ
 switch drivers.
Date: Fri, 8 Sep 2017 00:40:38 +0200
Message-ID: <20170907224038.GX11248@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
 <20170907212449.GQ11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121AFB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121AFB@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> > > ---
> > > diff --git a/drivers/net/dsa/microchip/Makefile
> > > b/drivers/net/dsa/microchip/Makefile
> > > index ed335e2..0961c30 100644
> > > --- a/drivers/net/dsa/microchip/Makefile
> > > +++ b/drivers/net/dsa/microchip/Makefile
> > > @@ -1,2 +1,2 @@
> > > -obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz_common.o
> > > +obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz9477.o ksz_common.o
> > >  obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o
> > 
> > Hi Tristram
> > 
> > I would of thought this would break the build. You don't add ksz9477.c until the
> > next patch.
> > 
> > Each patch needs to compile, otherwise you break git bisect.
> > 
> >      Andrew
> 

> Eventually the file will need to be broken in two, so you would like
> to see all 3 changes (Makefile, ksz_common.c, and ksz9477.c) in 1
> patch file?

You cannot break the build. Each patch must compile on its own.

Breaking changes up into smaller chunks is good. Makes it easier to
review.  So think about how you can do it without breaking the build,
but have smaller changes. For example, move a group of functions at a
time?

	Andrew
