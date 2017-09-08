From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 16:12:25 +0200
Message-ID: <20170908141225.GE25219@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <20170907215417.GU11248@lunn.ch>
 <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tristram.Ha@microchip.com, Pavel Machek <pavel@ucw.cz>,
        Nathan Conrad <nathan.leigh.conrad@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Maxim Uvarov <muvarov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 04:32:35PM +0300, Maxim Uvarov wrote:
> 2017-09-08 0:54 GMT+03:00 Andrew Lunn <andrew@lunn.ch>:
> >> -- compatible: For external switch chips, compatible string must be exactly one
> >> -  of: "microchip,ksz9477"
> >> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
> >> +           "microchip,ksz8795" for KSZ8795 chip,
> >> +           "microchip,ksz8794" for KSZ8794 chip,
> >> +           "microchip,ksz8765" for KSZ8765 chip,
> >> +           "microchip,ksz8895" for KSZ8895 chip,
> >> +           "microchip,ksz8864" for KSZ8864 chip,
> >> +           "microchip,ksz8873" for KSZ8873 chip,
> >> +           "microchip,ksz8863" for KSZ8863 chip,
> >> +           "microchip,ksz8463" for KSZ8463 chip
> >
> 
> all that chips have the same spi access to get chip id on probe(). I
> prefer common microship,ksz-spi rather than somebody will always
> maintain that list.

The Marvell DSA driver is similar. The compatibility string tells you
enough to go find the switch ID in the switch itself.

I suppose this comes down to, is there going to be one SPI driver for
all the devices, or lots of drivers? In general, DSA has one driver
for lots of devices. The mv88e6xxx supports around 25 devices. The b53
has around 17, etc.

So i would suggest one driver supporting all the different devices.

   Andrew
