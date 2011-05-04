From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: Transfer of maintainership
Date: Wed, 4 May 2011 09:36:09 +0200
Message-ID: <201105040936.09156.oneukum@suse.de>
References: <201104291419.04498.oneukum@suse.de> <20110504054511.GA3362@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	USB list <linux-usb@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35332 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212Ab1EDHed convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 03:34:33 -0400
In-Reply-To: <20110504054511.GA3362@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 4. Mai 2011, 07:45:11 schrieb Richard Cochran:
> On Fri, Apr 29, 2011 at 02:19:04PM +0200, Oliver Neukum wrote:
>=20
> >  USB "USBNET" DRIVER FRAMEWORK
> > -M:	David Brownell <dbrownell@users.sourceforge.net>
> > +M:	Oliver Neukum <oneukum@suse.de>
>=20
> Oliver,
>=20
> We have been looking at usbnet and a have question.
>=20
> Usbnet doesn't use either phylib or napi, but I think the reason is
> probably purely historical. Is there a technical reason why phylib or
> napi won't work with usbnet devices?

Hi,

phylib is for historical reasons, although many devices won't
give you much access to the phy.

NAPI however is technically not very meaningful for USB
devices as you cannot poll them. So the central concept
behind NAPI doesn't apply.

	Regards
		Oliver
--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
