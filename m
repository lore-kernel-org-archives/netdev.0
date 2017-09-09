From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Sat, 9 Sep 2017 01:44:37 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
 <20170908215735.GF27428@amd>
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
In-Reply-To: <20170908215735.GF27428@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Pavel Machek [mailto:pavel@ucw.cz]
> Sent: Friday, September 08, 2017 2:58 PM
> To: Tristram Ha - C24268
> Cc: andrew@lunn.ch; muvarov@gmail.com; nathan.leigh.conrad@gmail.com;
> vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh -
> C21699
> Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
> 
> Hi!
> 
> > > > +	default:
> > > > +		processed = false;
> > > > +		break;
> > > > +	}
> > > > +	if (processed)
> > > > +		*val = data;
> > > > +}
> > >
> > > Similar code will be needed by other drivers, right?
> >
> > Although KSZ8795 and KSZ8895 may use the same code, the other
> > chips will have different code.
> 
> Ok, please make sure code is shared between these two.

The exact function probably cannot be shared between KSZ8795
and KSZ8895 drivers because although the register constants look
the same but their exact locations are different in the 2 chips.
