From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 20:35:17 +0100
Message-ID: <201103232035.18232.arnd@arndb.de>
References: <4D79F068.2080009@linaro.org> <201103231756.39849.arnd@arndb.de> <20110323184650.GB21728@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andy.green@linaro.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	Linux USB list <linux-usb@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	broonie@opensource.wolfsonmicro.com, roger.quadros@nokia.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110323184650.GB21728@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 March 2011 19:46:50 Greg KH wrote:
> Looks good to me, but some questions:
> 
> >  drivers/usb/serial/usb_wwan.c |    2 +-
> 
> You don't modify this file in the diff, what caused this to show up in
> the diffstat?

A stale change I had to do to get the kernel to build on my
machine. The original problem seems fixed now. I had removed
this hunk from the patch but forgot to remove it from the diffstat.

> > --- a/include/linux/usb/usbnet.h
> > +++ b/include/linux/usb/usbnet.h
> > @@ -97,6 +97,8 @@ struct driver_info {
> >  
> >  #define FLAG_LINK_INTR       0x0800          /* updates link (carrier) status */
> >  
> > +#define FLAG_PTP     0x1000          /* maybe use "usb%d" names */
> 
> "PTP"?  What does that stand for?

point-to-point, I'll improve the comment to spell it out when I send the
fixed version.

	Arnd
