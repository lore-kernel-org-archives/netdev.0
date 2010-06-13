From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 1/4] net/phy/marvell: Expose IDs and flags in a .h and
	add dns323 LEDs setup flag
Date: Sun, 13 Jun 2010 07:28:31 +0200
Message-ID: <20100613052831.GA17012@pengutronix.de>
References: <1276391423.1962.263.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0F1p//8PRICkK4MW"
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Nicolas Pitre <nico@fluxnic.net>, hvr@gnu.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48101 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab0FMF2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 01:28:35 -0400
Content-Disposition: inline
In-Reply-To: <1276391423.1962.263.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 13, 2010 at 11:10:23AM +1000, Benjamin Herrenschmidt wrote:
> This moves the various known Marvell PHY IDs to include/linux/marvell_phy=
=2Eh
> along with dev_flags definitions for use by the driver.
>=20
> I then added a flag that changes the PHY init code to setup the LEDs
> config to the values needed to operate a dns323 rev C1 NAS.
>=20
> I moved the existing "resistance" flag to the .h as well, though I've
> been unable to find whoever sets this to convert it to use that constant.
>=20
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

That should do for now.

Reviewed-by: Wolfram Sang <w.sang@pengutronix.de>

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--0F1p//8PRICkK4MW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwUbH8ACgkQD27XaX1/VRvQaACfZi24wCDNd6i0RvaxItAYuSEs
Ep8AnAu/MG0ZnZZKkvEMCyBd9C0z6tpy
=dK8W
-----END PGP SIGNATURE-----

--0F1p//8PRICkK4MW--
