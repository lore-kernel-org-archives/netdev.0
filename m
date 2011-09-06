From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Tue, 6 Sep 2011 08:14:23 +0200
Message-ID: <201109060814.24127.oneukum@suse.de>
References: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com> <CAPopfEXz+HPdwWh_GQ2WzMnHh5DuXTse78NAU=-iN15wv-0C5g@mail.gmail.com> <CAPopfEXgR68y=Hsmx4q4Up7NqhLmbZ03N1=50eKKaB8EJ0aHfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jim Wylder <jwylder1@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55765 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab1IFGK7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 02:10:59 -0400
In-Reply-To: <CAPopfEXgR68y=Hsmx4q4Up7NqhLmbZ03N1=50eKKaB8EJ0aHfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 5. September 2011, 18:36:54 schrieb Jim Wylder:
> Oliver,
>=20
> I have a couple of questions about this:
>=20
> - Does the macro as implemented properly communicate the intent as yo=
u
> requested?

Yes.

> - You made a comment about this being useful outside of usbnet.  The
> only appropriate place that I could identify for this would be all th=
e
> way up in usb.h.  Do you think something at that level is more
> appropriate?

It is specific to usb. It belongs in the core device code.

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
