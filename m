From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH] DSA support for Micrel KSZ8895
Date: Wed, 30 Aug 2017 21:32:07 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD4111FA48@CHN-SV-EXMX02.mchp-main.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd> <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd> <20170828140927.GD10418@lunn.ch>
 <20170829074547.GB31303@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Woojung.Huh@microchip.com>, <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <andrew@lunn.ch>
To: <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170829074547.GB31303@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon 2017-08-28 16:09:27, Andrew Lunn wrote:
> > > I may be confused here, but AFAICT:
> > >
> > > 1) Yes, it has standard layout when accessed over MDIO.
> >
> >
> > Section 4.8 of the datasheet says:
> >
> > 	All the registers defined in this section can be also accessed
> > 	via the SPI interface.
> >
> > Meaning all PHY registers can be access via the SPI interface. So you
> > should be able to make a standard Linux MDIO bus driver which performs
> > SPI reads.
> 
> As far as I can tell (and their driver confirms) -- yes, all those registers can be
> accessed over the SPI, they are just shuffled around... hence MDIO
> emulation code. I copied it from their code (see the copyrights) so no, I don't
> believe there's nicer solution.
> 
> Best regards,
> 
> 									Pavel

Can you hold on your developing work on KSZ8895 driver?  I am afraid your effort may be in vain.  We at Microchip are planning to release DSA drivers for all KSZ switches, starting at KSZ8795, then KSZ8895, and KSZ8863.

The driver files all follow the structures of the current KSZ9477 DSA driver, and the file tag_ksz.c will be updated to handle the tail tag of different chips, which requires including the ksz_priv.h header.  That is required nevertheless to support using the offload_fwd_mark indication.

The KSZ8795 driver will be submitted after Labor Day (9/4) if testing reveals no problem.  The KSZ8895 driver will be submitted right after that.  You should have no problem using the driver right away.

Tristram Ha
Principal Software Engineer
Microchip Technology Inc.
