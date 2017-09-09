From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Sat, 9 Sep 2017 17:45:34 +0200
Message-ID: <20170909154534.GA19117@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
 <20170908215735.GF27428@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavel@ucw.cz, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 09, 2017 at 01:44:37AM +0000, Tristram.Ha@microchip.com wrote:
> > -----Original Message-----
> > From: Pavel Machek [mailto:pavel@ucw.cz]
> > Sent: Friday, September 08, 2017 2:58 PM
> > To: Tristram Ha - C24268
> > Cc: andrew@lunn.ch; muvarov@gmail.com; nathan.leigh.conrad@gmail.com;
> > vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh -
> > C21699
> > Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
> > 
> > Hi!
> > 
> > > > > +	default:
> > > > > +		processed = false;
> > > > > +		break;
> > > > > +	}
> > > > > +	if (processed)
> > > > > +		*val = data;
> > > > > +}
> > > >
> > > > Similar code will be needed by other drivers, right?
> > >
> > > Although KSZ8795 and KSZ8895 may use the same code, the other
> > > chips will have different code.
> > 
> > Ok, please make sure code is shared between these two.
> 
> The exact function probably cannot be shared between KSZ8795
> and KSZ8895 drivers because although the register constants look
> the same but their exact locations are different in the 2 chips.

You need to be careful with such functions. If they look identical,
somebody will try to consolidate them into one. So either you need to
do the consolidation yourself in order to get it right, or you need to
add a comment about how it differs.

    Andrew
