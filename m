From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 0/6] Modify KSZ9477 DSA driver in preparation to add
 other KSZ switch drivers.
Date: Sat, 9 Sep 2017 01:10:31 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41122FFB@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218B7@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
 <20170908085405.GB16834@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908085405.GB16834@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Pavel Machek [mailto:pavel@ucw.cz]
> Sent: Friday, September 08, 2017 1:54 AM
> To: Tristram Ha - C24268
> Cc: andrew@lunn.ch; muvarov@gmail.com; nathan.leigh.conrad@gmail.com;
> vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh -
> C21699
> Subject: Re: [PATCH RFC 0/6] Modify KSZ9477 DSA driver in preparation to
> add other KSZ switch drivers.
> 
> Hi!
> 
> > From: Tristram Ha <Tristram.Ha@microchip.com>
> >
> > This series of patches is to modify the original KSZ9477 DSA driver so that
> other KSZ switch drivers can be added and use the common code.
> >
> 
> Please wrap the lines from time to time...
> 
> 
> > This patch set is against net-next.
> >
> >  drivers/net/dsa/microchip/Makefile     |    2 +-
> >  drivers/net/dsa/microchip/ksz9477.c    | 1317
> ++++++++++++++++++++++++++++++++
> 
> We already have ksz_9477_reg.h. So should this be ksz_9477.c for
> consistency?

The product name is KSZ9477 and other switches are also like KSZ####,
so I would prefer to have no separation between KSZ and the product
number.  I think the file ksz_9477_reg.h was named that way because
the other files were named ksz_common.c and ksz_spi.c.  If need to
we can change the file name.
