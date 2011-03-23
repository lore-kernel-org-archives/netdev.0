From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 18:11:53 +0100
Message-ID: <201103231811.54290.arnd@arndb.de>
References: <4D79F068.2080009@linaro.org> <201103231756.39849.arnd@arndb.de> <4D8A2830.6020706@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	Linux USB list <linux-usb@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	broonie@opensource.wolfsonmicro.com, roger.quadros@nokia.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: andy.green@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D8A2830.6020706@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 March 2011, Andy Green wrote:
> > diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> > index bc86f4b..c98d3a7 100644
> > --- a/drivers/net/usb/smsc95xx.c
> > +++ b/drivers/net/usb/smsc95xx.c
> > @@ -1231,7 +1231,7 @@ static const struct driver_info smsc95xx_info = {
> 
> > -     .flags          = FLAG_ETHER | FLAG_SEND_ZLP,
> > +     .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_REALLY_ETHER,
> 
> >               if ((dev->driver_info->flags&  FLAG_ETHER) != 0&&
> > +                 ((dev->driver_info->flags&  FLAG_PTP) == 0 ||
> > +                  (net->dev_addr [0]&  0x02) == 0))
> >                       strcpy (net->name, "eth%d");
> 
> So it just takes the approach that all smsc95xx are going to be eth%d? 

Right, and all other drivers that are obviously ethernet-only, including
future drivers.

	Arnd
