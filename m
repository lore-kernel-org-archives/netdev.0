From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Freescale FEC packet loss
Date: Sun, 26 Jan 2014 21:33:33 +0000
Message-ID: <1390772013.2735.47.camel@deadeye.wl.decadent.org.uk>
References: <201401222255.29467.marex@denx.de>
	 <1390762590.2735.39.camel@deadeye.wl.decadent.org.uk>
	 <201401262012.13051.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ah7xa7C5lub6ewwT65TE"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>, fugang.duan@freescale.com,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	Hector Palacios <hector.palacios@digi.com>,
	linux-arm-kernel@lists.infradead.org, Detlev Zundel <dzu@denx.de>,
	Eric Nelson <eric.nelson@boundarydevices.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53754 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752461AbaAZVdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 16:33:43 -0500
In-Reply-To: <201401262012.13051.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ah7xa7C5lub6ewwT65TE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-01-26 at 20:12 +0100, Marek Vasut wrote:
> On Sunday, January 26, 2014 at 07:56:30 PM, Ben Hutchings wrote:
> > On Wed, 2014-01-22 at 22:55 +0100, Marek Vasut wrote:
> > > Hi guys,
> > >=20
> > > I am running stock Linux 3.13 on i.MX6Q SabreLite board. The CPU is
> > > i.MX6Q TO 1.0 .
> > >=20
> > > I am hitting a WARNING when I use the FEC ethernet to transfer data, =
thus
> > > I started investigating this problem. TL;DR I am not able to figure t=
his
> > > problem out, so I am not attaching a patch :-(
> > >=20
> > > Steps to reproduce:
> > > -------------------
> > > 1) Boot stock Linux 3.13 on i.MX6Q SabreLite board
> > > 2) Plug in an SD card into one of the SD slots (I use the full-size o=
ne)
> > > 3) Plug in an USB stick into one of the USB ports (I use the upper on=
e)
> > > 4) Plug in an ethernet cable into the board
> > >=20
> > >    -> Connect the other side into a gigabit-capable PC
> >=20
> > [...]
> >=20
> > I think there are known problems with 1000BASE-T on the Sabre Lite
> > board.
>=20
> This is MX6-wide thing, not sabrelite specific actually.
>=20
> > Two possible workarounds are to limit the PHY to 100BASE-TX
> > (should be doable with ethtool) or force it to be clock master for
> > 1000BASE-T (requires a driver patch).
>=20
> Can you please elaborate on the later ? I don't quite understand that.

1000BASE-T uses all 4 pairs in both directions at the same time, which
requires that both ends transmit symbols synchronously.  As part of the
autonegotiation protocol, they decide which is the clock master (using a
local clock generator) and which is the clock slave (generating a clock
from the received signal).  A PHY can be configured to support only one
of these roles.

> > The vendor kernel apparently does both!
>=20
> More like the vendor kernel papers over this bug.
>=20
> > Matthew Garrett has been trying to implement a workaround in a
> > clean way.
>=20
> Do you have any pointers about this please ?

http://thread.gmane.org/gmane.linux.drivers.devicetree/58570

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.

--=-ah7xa7C5lub6ewwT65TE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuV/Lee/yOyVhhEJAQqptRAAl2Ml3Mq/w4qManjiXZ3EoW1zom0D4jdf
SP4oywbbuprFXy0hwlrHCnCwUIsFMznAQsQu7ZcjncGct6ehl715uT3/Hg1WLW3e
jiZPnz/4F6bfLcjjE6VoBBRopW6Ebkr6AXlpbU8wIAti2ow/peIdnQDDSQ0eEqG3
GgPjrhIF0VsFvZk6jo8aMAohkzRFANhYStTSVD8UOZJC/gcYSk5RLvTLpQAB2RW9
dLNafkafT43GXAFctsR8NuWnBEujRzXgHhHj7sITsLHwuq6ZUAF/+XGX7SGz0Ccq
qBfjG1ZzMTWqej/dkTpUFwkek7I54Gk1X6qVbwg9bcmrsT9ONI/QPR3r1Bi+aA+j
HCCUW+nDu1i34k7Sk5d0o/o1ZHsrYkDNSJfgRBULZI2qrm0WwN8CA6ZMLUetJtWU
Udv5oAmnX+4OY+QaDr0aeV5oDR8aKAUGbycgnv66lgVUi2fAq+LawUmPDyqbxg2T
8eS2+RxhIjSTJYlUP7I+u7Rbb+5JwK5JRoRzSklusx3LjOxDfw4c0HfPwJO4B0lI
xGp5yOJM62usov4vg3N/Ql+DyCQG07umtlvodtgQ7LqsXUu2nXAVWExveqLjzAgp
9k24BmnuELf48qDFWFPUN07FtgaAsvyb8nMo3ZiVohoB8y71v9mBvtzHhe07HhBF
FV7CnI7RhnU=
=TC7r
-----END PGP SIGNATURE-----

--=-ah7xa7C5lub6ewwT65TE--
