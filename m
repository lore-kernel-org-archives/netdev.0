From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning
 to debug message
Date: Wed, 21 Sep 2011 14:59:05 +0200
Message-ID: <20110921125905.GI1966@pengutronix.de>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
 <20110921112555.GE1966@pengutronix.de>
 <20110921120341.GG28907@S2100-06.ap.freescale.net>
 <20110921121159.GG1966@pengutronix.de>
 <20110921124423.GI28907@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uJWb33pM2TcUAXIl"
Cc: Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, patches@linaro.org,
	netdev@vger.kernel.org,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-arm-kernel@lists.infradead.org,
	Lothar =?iso-8859-15?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54872 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab1IUM7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 08:59:09 -0400
Content-Disposition: inline
In-Reply-To: <20110921124423.GI28907@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uJWb33pM2TcUAXIl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> > I agree that keeping it int is way better. But why not add it now to
> > keep things proper and tested? If this patch gets accepted as it is and
> > later someone else will add error checking to the caller, your platform
> > will lose FEC support as a regression.
> >=20
> Again, fec_reset_phy() failure is not a show-stopper.  We might not
> want to make the probe fail because of that.

That would be an argument to make the function returning void?

Well, I still think something like=20

	/* No phy reset configured */
	if (phy_reset =3D=3D -ENODEV)
		return 0;

might be cleaner, yet I don't have the setup to test such an approach.

So, I'll be quiet now and hope for no problems.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--uJWb33pM2TcUAXIl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk5535kACgkQD27XaX1/VRuhGQCfdZ5wqP0VxpCVdmg8IOodm9WB
n4YAnR65I6lNP8uIxExMIPYGRIHIAqF4
=DR/n
-----END PGP SIGNATURE-----

--uJWb33pM2TcUAXIl--
