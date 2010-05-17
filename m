From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] phy/marvell: Add special settings for D-Link DNS-323
	rev C1
Date: Mon, 17 May 2010 14:00:32 +0200
Message-ID: <20100517120032.GI22781@pengutronix.de>
References: <1274056058.21352.697.camel@pasglop> <20100517005942.GB27301@pengutronix.de> <1274058457.21352.711.camel@pasglop> <1274096214.21352.735.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="81JctsDUVPekGcy+"
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@fluxnic.net>,
	linux-arm-kernel@lists.infradead.org,
	Herbert Valerio Riedel <hvr@gnu.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47430 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab0EQMAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 08:00:37 -0400
Content-Disposition: inline
In-Reply-To: <1274096214.21352.735.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--81JctsDUVPekGcy+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> The problem is that the fixups are called -after- the config_init()
> callback of the PHY driver. However, the marvell m88e1118 PHY driver
> will unconditionally reset the LEDs setting.

Haven't checked, just an idea: Is it possible to change the init of the dri=
ver
to use Read-Modify-Write and thus keep your settings?

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--81JctsDUVPekGcy+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkvxL+AACgkQD27XaX1/VRtjEwCgjQi2/cN8orz1BS+rhQFUMtP3
vN0AniajQRB8b7n+QsqbvrPNrtPi8gCL
=JO0T
-----END PGP SIGNATURE-----

--81JctsDUVPekGcy+--
