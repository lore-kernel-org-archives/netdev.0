From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 5/5] drivers: net: usb: rtl8150: making the code a bit
 better looking
Date: Mon, 20 May 2013 22:16:33 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305202208460.3400@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305182314500.16874@fry.nucleusys.com> <1369061535.4616.2.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369061535.4616.2.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 May 2013, Ben Hutchings wrote:

> [...]
> > @@ -771,12 +770,12 @@ static void rtl8150_disconnect(struct usb_interface *intf)
> >  }
> >  
> >  static struct usb_driver rtl8150_driver = {
> > -	.name		= driver_name,
> > -	.probe		= rtl8150_probe,
> > -	.disconnect	= rtl8150_disconnect,
> > -	.id_table	= rtl8150_table,
> > -	.suspend	= rtl8150_suspend,
> > -	.resume		= rtl8150_resume,
> > +	.name = driver_name,
> > +	.probe = rtl8150_probe,
> > +	.disconnect = rtl8150_disconnect,
> > +	.id_table = rtl8150_table,
> > +	.suspend = rtl8150_suspend,
> > +	.resume = rtl8150_resume,
> >  	.disable_hub_initiated_lpm = 1,
> >  };
> 
> These looked better before.  Lining up initialisers in a structure 
> definition is good style.

It is.  This is what i usually do.  However, scripts/Lindent is messed up 
in (not only) this regard.  IMHO it should not be used as it is.

I thought using what is recommended (at least in the documentation) makes 
me a good citizen even though i don't like the end result much.

Again, the above is true in case i've not misunderstood something, 
somewhere.


		Petko
