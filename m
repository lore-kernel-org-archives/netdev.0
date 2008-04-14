From: "Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Mon, 14 Apr 2008 23:42:07 +0100
Message-ID: <200804142342.08116.ajb@spheresystems.co.uk>
References: <20080414213238.GB28833@kroah.com> <20080414215905.GD16272@one-eyed-alien.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Filip Aben <f.aben@option.com>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: Matthew Dharm <mdharm-usb@one-eyed-alien.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from maggie.spheresystems.co.uk ([82.71.70.17]:36198 "EHLO
	maggie.spheresystems.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753475AbYDNXEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 19:04:44 -0400
In-Reply-To: <20080414215905.GD16272@one-eyed-alien.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matthew,
	I'd prefer the keep it as just 'hso' and change the textual description if 
necessary. I think module names are just arbitrary, and should not 
necessarily reflect the original usage too well, otherwise you end up with a 
situation like with the 'option' module. That module is now used for many 
devices from differing manufacturers and it doesn't really make much sense to 
load the option module to service a device from Novatel, Sierra Wireless or 
Huawei.

Just my two pence,


Andrew


On Monday 14 April 2008 22:59, Matthew Dharm wrote:
> I will be the first to admit that I'm picking a nit here, but...
>
> On Mon, Apr 14, 2008 at 02:32:39PM -0700, Greg KH wrote:
> > Subject: USB: add option hso driver
> >
> > +config USB_HSO
> > +	tristate "Option USB High Speed Mobile Devices"
> >
> > + * Driver for Option High Speed Mobile Devices.
> >
> > +#define MOD_DESCRIPTION			"USB High Speed Option driver"
>
> Would it be possible to pick one of "High Speed Option" and "Option...
> High Speed" and then be consistent with the acronym of "hso" or "ohs"?  Or
> maybe call it "option_hs" or something even more clear?
>
> Mixing them just makes it more difficult for people to use grep and google.
>
> Matt
