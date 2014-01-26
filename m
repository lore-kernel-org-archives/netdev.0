From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Freescale FEC packet loss
Date: Sun, 26 Jan 2014 18:56:30 +0000
Message-ID: <1390762590.2735.39.camel@deadeye.wl.decadent.org.uk>
References: <201401222255.29467.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-thPrUAxZRYiV8+um/61i"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>, fugang.duan@freescale.com,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	Hector Palacios <hector.palacios@digi.com>,
	linux-arm-kernel@lists.infradead.org, Detlev Zundel <dzu@denx.de>,
	Eric Nelson <eric.nelson@boundarydevices.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53455 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752397AbaAZS4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 13:56:41 -0500
In-Reply-To: <201401222255.29467.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-thPrUAxZRYiV8+um/61i
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-22 at 22:55 +0100, Marek Vasut wrote:
> Hi guys,
>=20
> I am running stock Linux 3.13 on i.MX6Q SabreLite board. The CPU is i.MX6=
Q TO=20
> 1.0 .
>=20
> I am hitting a WARNING when I use the FEC ethernet to transfer data, thus=
 I=20
> started investigating this problem. TL;DR I am not able to figure this pr=
oblem=20
> out, so I am not attaching a patch :-(
>=20
> Steps to reproduce:
> -------------------
> 1) Boot stock Linux 3.13 on i.MX6Q SabreLite board
> 2) Plug in an SD card into one of the SD slots (I use the full-size one)
> 3) Plug in an USB stick into one of the USB ports (I use the upper one)
> 4) Plug in an ethernet cable into the board
>    -> Connect the other side into a gigabit-capable PC
[...]

I think there are known problems with 1000BASE-T on the Sabre Lite
board.  Two possible workarounds are to limit the PHY to 100BASE-TX
(should be doable with ethtool) or force it to be clock master for
1000BASE-T (requires a driver patch).  The vendor kernel apparently does
both!  Matthew Garrett has been trying to implement a workaround in a
clean way.

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.

--=-thPrUAxZRYiV8+um/61i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuVaXue/yOyVhhEJAQofvBAA1XfwiHqzpnPgrc1MctvBF5RGdeDJTx5E
ElyuysvbUC8mJnueiuU0LpbO5w4vBptzK2dIu7DmS4kHM8K4Hw4CcKv+cJr+lKOp
voi3GgVxvS3xRpxbfkBWvXOK2jbWUQkxuDeH+1YstLT/45NDd67EPuAs+1/ErDFU
mq4KSAA6Iz6LLhr8qu1So4gJsqpZRQfdxYfbf1XncJJEb7agcyV6WE58iUTXD+CQ
NSai7GFbpHVZqVE/brA6Ha1X8xhn9ALOT1yk4LjqpakRpjWUbX7a2oO3O566cZRB
II/o1lEWKf3sd4w4bvnIzCFOSldSdO7HzTCeKmVX4+VHvNd6edJ756turi7rHvhq
XshYt3wecMjY3zonObB2cnZRbQuCM3w30zvW286vrXwDSdEo56hqFdlfLU32LbQ/
O3kWoJ0wg7e/GyFleuB1LL56dgk1w7ZyWw2ZqtbKg0OQ3us0XCFLEPTN4fOHmczG
qzbzTrBMWvTg/oYnvc2IPXq5WstJh+onLAR0KDU/b3w7Pkp2Bm8+/ircy0jbqgTs
Hen6DTMxedlLi64BfaQf7F8Zy5cztZGfN2EDG+5dWoACbO1rJJBOfhNz9y2h4mqb
f7wvDFVbYS1jMK80EK5yJSwZLCCW3KWXoP+1akAZ/T4779bAAE5drodo5k6x6jB6
++2FT4PSj7I=
=KIZy
-----END PGP SIGNATURE-----

--=-thPrUAxZRYiV8+um/61i--
