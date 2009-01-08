From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 5/5] Phonet: USB CDC Phonet function for gadget
 framework
Date: Thu, 08 Jan 2009 18:15:05 +0100
Message-ID: <1231434905.5298.22.camel@californication>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
	 <1229522874-20636-5-git-send-email-remi.denis-courmont@nokia.com>
	 <1230565448.15666.25.camel@californication>
	 <200901080954.01181.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49840 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbZAHRPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 12:15:07 -0500
In-Reply-To: <200901080954.01181.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> > > This implements the Nokia vendor-specific communication device cl=
ass
> > > function to exchange Phonet messages over USB. This function is a=
lready
> > > found in the "PC suite" USB profile of (non-Linux) Nokia handsets=
=2E
> > >
> > > Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@noki=
a.com>
> > > ---
> > >  drivers/usb/gadget/f_phonet.c |  621
> > > +++++++++++++++++++++++++++++++++++++++++ drivers/usb/gadget/u_ph=
onet.h |
> > >   21 ++
> > >  2 files changed, 642 insertions(+), 0 deletions(-)
> > >  create mode 100644 drivers/usb/gadget/f_phonet.c
> > >  create mode 100644 drivers/usb/gadget/u_phonet.h
> >
> > any reason why you didn't add an option to Kconfig to actually sele=
ct
> > this gadget?
>=20
> Yeah: this is NOT a gadget. This is a function for any gadget that wi=
shes to=20
> use it. Same as the OBEX function in fact. What would be needed is a =
Kconfig=20
> for some gadget that actually uses that.
>=20
> A -slightly outdated- example is here:
> http://repository.maemo.org/pool/maemo5.0/free/k/kernel/

I see. Makes sense to me now. Any reason why the g_nokia gadget is not
merged upstream? Would be nice to have this around for actually testing
the PhoNet stuff.

Regards

Marcel


