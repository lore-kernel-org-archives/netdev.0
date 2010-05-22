From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 1/5] net/phy/marvell: Expose IDs and flags in a .h and
	add dns323 LEDs setup flag
Date: Sat, 22 May 2010 15:06:24 +0200
Message-ID: <20100522130624.GA28561@pengutronix.de>
References: <1274525683.1931.139.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Nicolas Pitre <nico@fluxnic.net>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45250 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab0EVNG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 09:06:28 -0400
Content-Disposition: inline
In-Reply-To: <1274525683.1931.139.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 22, 2010 at 08:54:43PM +1000, Benjamin Herrenschmidt wrote:
> This moves the various known Marvell PHY IDs to include/linux/marvell_phy=
=2Eh
> along with dev_flags definitions for use by the driver.

I think this one from the driver should go there, too:

#define M1145_DEV_FLAGS_RESISTANCE      0x00000001

(which makes me wonder how this flag was set as it was not exported before)

and thus yours could be maybe like

#define M1118_DEV_FLAGS_ALT_LED_INIT	0x00000001

(or 1 << 0)

?

Otherwise looks good enough to me.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkv31tAACgkQD27XaX1/VRuwoACgyzcfXCt9MVMaBrcTiR/WiIOX
+6YAniNRquOfep1hynajDwUAi21895xj
=Q3fu
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
