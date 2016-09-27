From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v3 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 27 Sep 2016 16:58:49 +0200
Message-ID: <20160927145849.GK28432@lunn.ch>
References: <1474984075-12312-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160927141633.GJ28432@lunn.ch>
 <20160927142659.GC10776@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: "Allan W. Nielsen" <allan.nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160927142659.GC10776-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 04:26:59PM +0200, Allan W. Nielsen wrote:
> Hi Andrew,
> 
> > > +Optional properties:
> > > +- vsc8531,edge-rate  : Edge rate sets the drive strength of the MAC
> > > +                       interface output signals.  Changing the drive
> > > +                       strength will affect the edge rate of the output
> > > +                       signal.
> > 
> > Are we specifying a rate or a strength? It is called edge-rate, so it
> > expect it to be a rate, mV/pS or something similar.
> I do not know - sorry.

The text needs to be consistent with the property name. The text
suggests this setting affects the drive strength. As a result of the
drive strength, the edge rate will differ. Cause and effect.

So maybe the correct units here is mA?

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
