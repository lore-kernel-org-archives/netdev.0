From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 18:45:19 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD4112CBC8@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
 <20170908215735.GF27428@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
 <20170928152445.GC2482@amd>
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
In-Reply-To: <20170928152445.GC2482@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > > > Similar code will be needed by other drivers, right?
> > > >
> > > > Although KSZ8795 and KSZ8895 may use the same code, the other
> > > > chips will have different code.
> > >
> > > Ok, please make sure code is shared between these two.
> >
> > The exact function probably cannot be shared between KSZ8795
> > and KSZ8895 drivers because although the register constants look
> > the same but their exact locations are different in the 2 chips.
> 
> Put the code into header as static inline and include it from both
> places?
> 

Although KSZ8795 and KSZ8895 share the same code when simulating
the PHY register access, even though the exact registers are not the
same, this code needs a little modification for another chip.  It also looks
too large to put in a header.
