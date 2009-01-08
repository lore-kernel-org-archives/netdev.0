From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 5/5] Phonet: USB CDC Phonet function for gadget framework
Date: Thu, 8 Jan 2009 09:54:00 +0200
Message-ID: <200901080954.01181.remi.denis-courmont@nokia.com>
References: <200812171607.14184.remi.denis-courmont@nokia.com> <1229522874-20636-5-git-send-email-remi.denis-courmont@nokia.com> <1230565448.15666.25.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:27488 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbZAHHxh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 02:53:37 -0500
In-Reply-To: <1230565448.15666.25.camel@californication>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 29 December 2008 17:44:08 ext Marcel Holtmann, you wrote:
> > This implements the Nokia vendor-specific communication device clas=
s
> > function to exchange Phonet messages over USB. This function is alr=
eady
> > found in the "PC suite" USB profile of (non-Linux) Nokia handsets.
> >
> > Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.=
com>
> > ---
> >  drivers/usb/gadget/f_phonet.c |  621
> > +++++++++++++++++++++++++++++++++++++++++ drivers/usb/gadget/u_phon=
et.h |
> >   21 ++
> >  2 files changed, 642 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/usb/gadget/f_phonet.c
> >  create mode 100644 drivers/usb/gadget/u_phonet.h
>
> any reason why you didn't add an option to Kconfig to actually select
> this gadget?

Yeah: this is NOT a gadget. This is a function for any gadget that wish=
es to=20
use it. Same as the OBEX function in fact. What would be needed is a Kc=
onfig=20
for some gadget that actually uses that.

A -slightly outdated- example is here:
http://repository.maemo.org/pool/maemo5.0/free/k/kernel/

Regards,

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
