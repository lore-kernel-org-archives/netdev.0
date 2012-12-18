From: Lucas Stach <dev@lynxeye.de>
Subject: Re: [PATCH 1/2] net: asix: init ASIX AX88772B MAC from EEPROM
Date: Tue, 18 Dec 2012 14:38:32 +0100
Message-ID: <1355837912.1490.73.camel@tellur>
References: <1355832626-3034-1-git-send-email-dev@lynxeye.de>
	 <5491619.g500gaSnsh@linux-lqwf.site> <1355837072.1490.71.camel@tellur>
	 <1672154.FXjtO9OFRj@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km20343-01.keymachine.de ([84.19.182.79]:55303 "EHLO
	km20343-01.keymachine.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754716Ab2LRNid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 08:38:33 -0500
In-Reply-To: <1672154.FXjtO9OFRj@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 18.12.2012, 14:33 +0100 schrieb Oliver Neukum:
> On Tuesday 18 December 2012 14:24:32 Lucas Stach wrote:
> > Am Dienstag, den 18.12.2012, 14:11 +0100 schrieb Oliver Neukum:
> > > On Tuesday 18 December 2012 13:10:25 Lucas Stach wrote:
> > > > diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> > > > index 9bbeabf..8e9516f 100644
> > > > --- a/include/linux/usb/usbnet.h
> > > > +++ b/include/linux/usb/usbnet.h
> > > > @@ -106,6 +106,7 @@ struct driver_info {
> > > >   */
> > > >  #define FLAG_MULTI_PACKET      0x2000
> > > >  #define FLAG_RX_ASSEMBLE       0x4000  /* rx packets may span >1 frames */
> > > > +#define FLAG_EEPROM_MAC                0x8000  /* initialize device MAC from eeprom */
> > > 
> > > Hi,
> > > 
> > > this looks sensible, but
> > > why are you adding a flag unused in usbnet to usbnet.h?
> > 
> > Right, this might not be the right place to add this. Could you point me
> > to a more appropriate place? The data member of usbnet might be a good
> 
> driver_priv is intended for such stuff
> 
I'm not talking about the usbnet struct, but the driver_info struct. I
need a way to pass this flag from the static driver info to the bind
function. I don't even have a usbnet device at this point, where I could
hang on driver_priv data.

Regards,
Lucas
