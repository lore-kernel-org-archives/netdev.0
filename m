From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Mon, 27 Jan 2014 23:40:11 +0000
Message-ID: <1390866011.4405.2.camel@deadeye.wl.decadent.org.uk>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	 <1390823503-24087-1-git-send-email-alchark@gmail.com>
	 <1390823503-24087-4-git-send-email-alchark@gmail.com>
	 <1390834654.2735.148.camel@deadeye.wl.decadent.org.uk>
	 <CABjd4Yz2Kfed_qBfSAEXoAcVxfsmhTBA-83YJ9_iSwPZ+r1qYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lqUvMEKlP/A+W9wDQi+i"
Cc: netdev@vger.kernel.org, Tony Prisk <linux@prisktech.co.nz>,
	devicetree@vger.kernel.org, Roger Luethi <rl@hellgate.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey Charkov <alchark@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABjd4Yz2Kfed_qBfSAEXoAcVxfsmhTBA-83YJ9_iSwPZ+r1qYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lqUvMEKlP/A+W9wDQi+i
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 19:34 +0400, Alexey Charkov wrote:
> 2014/1/27 Ben Hutchings <ben@decadent.org.uk>:
> > On Mon, 2014-01-27 at 15:51 +0400, Alexey Charkov wrote:
> >> This should make the driver usable with VIA/WonderMedia ARM-based
> >> Systems-on-Chip integrated Rhine III adapters. Note that these
> >> are always in MMIO mode, and don't have any known EEPROM.
> > [...]
> >> --- a/drivers/net/ethernet/via/Kconfig
> >> +++ b/drivers/net/ethernet/via/Kconfig
> >> @@ -19,7 +19,7 @@ if NET_VENDOR_VIA
> >>
> >>  config VIA_RHINE
> >>         tristate "VIA Rhine support"
> >> -       depends on PCI
> >> +       depends on (PCI || USE_OF)
> >>         select CRC32
> >>         select MII
> >>         ---help---
> >
> > This seems like the right thing to do, but it means you need to add
> > #ifdef CONFIG_PCI and #ifdef CONFIG_USE_OF around the driver structures
> > and related functions.
>=20
> Frankly, I would like to avoid that if possible (as pointed out in the
> cover email), as I believe we would get a cleaner driver without
> #ifdef. This is also the way it was done in via-velocity, and it works
> just fine.

OK, I'm surprised that all the PCI functions have dummy definitions.

> > You should compile-test in configurations that have just one of those
> > dependencies enabled.
>=20
> This has been compile-tested and runtime-tested in OF-only
> configuration on WM8950, and Roger also tested it in PCI-only
> configuration, so it seems to work fine.
[...]

Good, then I have no objection.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-lqUvMEKlP/A+W9wDQi+i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUubuW+e/yOyVhhEJAQpVGQ//d1srlooIRbGRoSGeEH7zZbpAMv6grkeS
ABdZhue0hVQRq/dIIDmzwfkPHMYykjJPM7YTVY6tT2QJ+UCvgNBFCeG8kXBRTUMQ
Ybz02Od5YbqqY0IXPFFj3jrVixAk+Nwx6+DVwjP84+odUmg8UTn1V9IviXSk3Jfg
9qV9ut07SffsWYyDqHsf4zUmFPYIWXE8CCsXN3YMWCcKFkdhwVI7fbMQEazRLEHZ
QseVmmHGIoBS9KBfGc+aIHzME9wFIIAFbFouFlXY39+i70Wdkyf+GidS/TjP5nSF
0kumtirxSopbowlWsJSC2+Cd0vYz4P6tQQk/8t+9qR5VkgmNmSceyQtEZGfhvPx9
VMf7NhSJ1P8ASnoGiheEFgEgCLfBoNKnXmPtRVkhesZhp1iWUv7W6HOD/ot/gH2R
TKeBzsDA0WMXmkNntumStolS418lkF4IQz7EX4EXiLafxlJdnnNcZ/BYVYRd5na3
9X55qslsbrEaRt+3ZjJWmu3gp1N0Kmh3fVzlFsfiSQHJiso89OEer7LnpB/hcQBg
v6VQrIGaTG03pN2Bb9vQjW99v4IcKLD3pibCecSmOW9nPXiKTXPI+8KBSqoBDUly
RZ6ND+6xrX880gMNKOnyTfNwUJW6/0tCFtaRj05KEILmsPDcjuWADaBqiMy4rFEi
tn97EGF+hBg=
=3EKG
-----END PGP SIGNATURE-----

--=-lqUvMEKlP/A+W9wDQi+i--
