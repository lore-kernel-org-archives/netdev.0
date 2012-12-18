From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 1/2] net: asix: init ASIX AX88772B MAC from EEPROM
Date: Tue, 18 Dec 2012 14:33:23 +0100
Message-ID: <1672154.FXjtO9OFRj@linux-lqwf.site>
References: <1355832626-3034-1-git-send-email-dev@lynxeye.de> <5491619.g500gaSnsh@linux-lqwf.site> <1355837072.1490.71.camel@tellur>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355837072.1490.71.camel@tellur>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 December 2012 14:24:32 Lucas Stach wrote:
> Am Dienstag, den 18.12.2012, 14:11 +0100 schrieb Oliver Neukum:
> > On Tuesday 18 December 2012 13:10:25 Lucas Stach wrote:
> > > diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> > > index 9bbeabf..8e9516f 100644
> > > --- a/include/linux/usb/usbnet.h
> > > +++ b/include/linux/usb/usbnet.h
> > > @@ -106,6 +106,7 @@ struct driver_info {
> > >   */
> > >  #define FLAG_MULTI_PACKET      0x2000
> > >  #define FLAG_RX_ASSEMBLE       0x4000  /* rx packets may span >1 frames */
> > > +#define FLAG_EEPROM_MAC                0x8000  /* initialize device MAC from eeprom */
> > 
> > Hi,
> > 
> > this looks sensible, but
> > why are you adding a flag unused in usbnet to usbnet.h?
> 
> Right, this might not be the right place to add this. Could you point me
> to a more appropriate place? The data member of usbnet might be a good

driver_priv is intended for such stuff

> place to stuff this into, but why is this a plain long and not some kind
> of pointer? It is used for a different purpose on other ASIX chips
> already.

But there is another pointer.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
