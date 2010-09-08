From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] cxacru: ignore cx82310_eth devices
Date: Wed, 8 Sep 2010 22:56:05 +0200
Message-ID: <201009082256.07618.linux@rainbow-software.org>
References: <201009032317.14954.linux@rainbow-software.org> <201009052212.37015.linux@rainbow-software.org> <20100905210446.GA4472@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>,
	David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:60820 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754142Ab0IHU4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:56:14 -0400
In-Reply-To: <20100905210446.GA4472@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 September 2010 23:04:46 Greg KH wrote:
> On Sun, Sep 05, 2010 at 10:12:33PM +0200, Ondrej Zary wrote:
> > Ignore ADSL routers, which can have the same vendor and product IDs
> > as ADSL modems but should be handled by the cx82310_eth driver.
> >
> > This intentionally ignores device IDs that aren't currently handled
> > by cx82310_eth. There may be other device IDs that perhaps shouldn't
> > be claimed by cxacru.
> >
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> >
> > --- linux-2.6.36-rc3-orig/drivers/usb/atm/cxacru.c	2010-08-29
> > 17:36:04.000000000 +0200 +++
> > linux-2.6.36-rc3/drivers/usb/atm/cxacru.c	2010-09-05 18:54:56.000000000
> > +0200 @@ -1324,8 +1324,22 @@ static struct usbatm_driver cxacru_drive
> >  	.tx_padding	= 11,
> >  };
> >
> > -static int cxacru_usb_probe(struct usb_interface *intf, const struct
> > usb_device_id *id) -{
> > +static int cxacru_usb_probe(struct usb_interface *intf,
> > +		const struct usb_device_id *id) {
>
> Ick, what?
>
> Did you run this patch through scripts/checkpatch.pl?

Yes - and it passed. Maybe checkpatch.pl can't handle multiple lines there.

-- 
Ondrej Zary
