From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: r8169: only works in 10mbit/half duplex
Date: Tue, 09 May 2006 21:12:17 +0200
Message-ID: <1147201937.32169.41.camel@johannes.berg>
References: <1147137144.16487.61.camel@johannes.berg>
	 <20060509190110.GB3215@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1Tp+1lGFJo7u6BBE1ALc"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:15008 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750792AbWEITMd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 15:12:33 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060509190110.GB3215@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1Tp+1lGFJo7u6BBE1ALc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

> It's hard to tell without data. It could be any of the usual suspects
> or a genuine bug.

Yeah, I realise that. I've tried booting windows which behaves exactly
the same, with the latest realtek driver. I've sent back the machine
today because I need to have this box up fairly soon. Sorry :/

> Can you send the complete dmesg from boot + lspci -vvx + /proc/interrupts
> of the computer ?

I don't have a dmesg any more, lspci is at
http://johannes.sipsolutions.net/files/lspci-minipc, /proc/interrupts
looked normal as far as I can remember. dmesg didn't say much about
r8169, and other than that I didn't see any problems. I tried booting
with pci=3Drouteirq and some options but none of that helped, and
interrupts were definitely counted in all cases.

> What does ethtool report if you do not force it to 10Mbps with the media=
=3D1
> option and what hardware is it connected to ? Any URL for the motherboard=
 ?

Here's the weirdest thing:
If I connected it to 100mbit/full duplex hardware, it worked only if I
forced it to 10mbit (half or full), otherwise the tx/rx led would blink
frantically and the card didn't receive any packets (sending was fine).
If I connected it to gbit hardware it worked in gibt mode, but only got
transfer speeds of about 10mb/sec. Same behaviour with windows.

johannes

--=-1Tp+1lGFJo7u6BBE1ALc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARGDpj6Vg1VMiehFYAQJHRQ//cCDGjC4rKTTuM+hK5QNT1xsMXvi1YWNr
B7eN4Ek9VBJoaRNMRPizHtFHIVfbnNghQ2zJzcS6AfwxXeXJVaYf+yBomFXcvDDD
HhcnPPPGnIFLeOTHMADRVnbe+8LrPRTHJ//TWZwU+4vMVC/fMhLbWkio6mXj7+pz
IDwe94YnB7hkxSz0BybNk22c0GRHMghanRfeHMrVPCuWJqlGI6LFp4LxP0czpK9u
q3UnJzyaRW3FvGWYbi1ENapoP1eQG8k3So53hhAs3TcTRj9/sipA2jDwXxb1J7tu
mD+zoKzztb6JyMdin/4h6ZnIWMhPDReGjdhf9+CLFgozQKaG5VGDresZOCA9ZQg6
sBUS4CSxS4rwG+WCXLv/iAgIsudA4jrVFyvbpr1219Gf/5PxDwEbVtQUODI/vV5q
Hq7eijntiVafPxJVCL2NjPt+JXYhBHIrJt48WVdcsw0xvgtFeDRp7PA65tjd0oQ3
zomrCItcQkdy8jPTuFf8n7H0xITuPrn6LENf9/nCWkTxpgQW+DsJagvB5wQRvgWD
JZjoc8PgSIeKgFCSzAWBSH3ow9j0V4b4tgaxHZ6COAbA3wXzOavZpJaL3xrWIQU1
Vc84YJ3WkH/gq7JrlIaXpfNWNMqqpNTkhoaYTdotU7Opjahbqz2PY92zXk/FlUQe
aZezKjEFDrA=
=DvAg
-----END PGP SIGNATURE-----

--=-1Tp+1lGFJo7u6BBE1ALc--

