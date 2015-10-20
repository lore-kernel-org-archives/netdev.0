From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: removed USB_USBNET as a config option
Date: Tue, 20 Oct 2015 08:28:59 +0200
Message-ID: <1445322539.2246.1.camel@suse.com>
References: <1445257387-4278-1-git-send-email-oneukum@suse.com>
	 <87oafuu0ru.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55726 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbbJTGa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 02:30:57 -0400
In-Reply-To: <87oafuu0ru.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-10-19 at 21:16 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.com> writes:
>=20
> > usbnet drives no devices of its own. It makes more sense to
> > select it whenever a driver for actual hardware that needs
> > it is chosen rather than offer it as an option of its own.
> >
> > Signed-off-by: Oliver Neukum <oneukum@suse.com>
> > ---
> >  drivers/net/usb/Kconfig | 75 +++++++++++++++----------------------=
------------
> >  1 file changed, 23 insertions(+), 52 deletions(-)
> >
> > diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> > index 8cf0eba..0cf45ab 100644
> > --- a/drivers/net/usb/Kconfig
> > +++ b/drivers/net/usb/Kconfig
> > @@ -119,42 +119,12 @@ config USB_LAN78XX
> >  	  module will be called lan78xx.
> > =20
>=20
> This looks incomplete.

Yes, it is against the earlier patch set which introduces the CDC
parser in cdc-acm and cdc-wdm. In hindsight I should have reversed
the order of patches.

	Regards
		Oliver
