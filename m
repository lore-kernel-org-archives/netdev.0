From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] netdev/fec: fix ifconfig eth0 down hang issue
Date: Fri, 28 May 2010 16:45:06 +0200
Message-ID: <20100528144506.GB13777@pengutronix.de>
References: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FkmkrVfFsRoUs1wW"
Cc: davem@davemloft.net, afleming@gmail.com, s.hauer@pengutronix.de,
	gerg@uclinux.org, amit.kucheria@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52835 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757375Ab0E1OpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 10:45:10 -0400
Content-Disposition: inline
In-Reply-To: <1275037685-14555-1-git-send-email-bryan.wu@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 28, 2010 at 05:08:05PM +0800, Bryan Wu wrote:
> BugLink: http://bugs.launchpad.net/bugs/559065
>=20
> In fec open/close function, we need to use phy_connect and phy_disconnect
> operation before we start/stop phy. Otherwise it will cause system hang.
>=20
> Only call fec_enet_mii_probe() in open function, because the first open
> action will cause NULL pointer error.
>=20
> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>

We use this patch for 1 month now and didn't encounter any flaws so far.

Tested-by: Wolfram Sang <w.sang@pengutronix.de>

Oops, too late... well, one for the comfortable feeling ;)

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--FkmkrVfFsRoUs1wW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkv/1vIACgkQD27XaX1/VRts1wCdGd2G46UyGCSelOVlZd8wk4zW
vVIAn3qc5kP5a2Ccaky4uQJZP25Ef1KN
=pUk+
-----END PGP SIGNATURE-----

--FkmkrVfFsRoUs1wW--
