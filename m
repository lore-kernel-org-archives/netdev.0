From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: mark constant as ULL
Date: Wed, 04 Feb 2015 09:49:37 -0800
Message-ID: <1423072177.2589.66.camel@jtkirshe-mobl>
References: <1423050064-25087-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-l7pSCQGAdUdnfF2Vp/vD"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	e1000-devel@lists.sourceforge.net
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65491 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161186AbbBDRto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 12:49:44 -0500
In-Reply-To: <1423050064-25087-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-l7pSCQGAdUdnfF2Vp/vD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-04 at 12:41 +0100, Stefan Assmann wrote:
> This avoids a compile error on 32bit.
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Come to find out, I already have a fix in my queue for this.  So I will
be dropping your patch.

The patch in my queue fixes the issue by doing the folling change:
-               mask =3D 0xFFFFFFFFFFFFFFFF;
+               mask =3D ~(u64)0;

--=-l7pSCQGAdUdnfF2Vp/vD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU0luxAAoJEOVv75VaS+3OFSYP/A684FzmkVBCDgt8fhpZT/hr
kEbV/toU2ibjbU3WvV3cYDddFMhHKt9lc7sKStmrOXHKHB8X1iPAUzMssmhbLfL8
nGlwziTYV/J6rho1h8YO7UoYZA/Vy1+Dtql2ZK/ILG+vcWXZfghoVGF9yHw3rEOk
8r05pije1cICJ4fw4RfkQ/kgfXj1wXApOXaXP++66TkWm3u5OPLcGqrevKhbNP+S
9m65LkNxWZvALKCivb7QzTS1NksQ5F52ZZ9ui48xgky42L/Yzegpqe7mTNtVWqTc
Eb4VxaJ+Q6F9bgV4J4luwxTvXQcT0gS5ihmpWHLZEA/HugnQ0iCMO1ztajrUsdSC
sy3hSKnw/iEU3pvwnolosKa/2q8EEKQXd5UWGoAWogHAbL21+ebytAa3LVYcUzo2
Y7ck2gt1n730N5oBSE2/1YR8E2D7wNzZbDk91ZW4vtVsaOhNoHDvBBl+FuFycgaS
y1RqsqXR8R/u2VElR/xcPWTxJzeQ7panqKOtVeUxVG8M+v9JlV2su57zD2PK/D7a
YmXO62uGoIhvMYGjVqDx80IgQGaADavb7STA1SSPWJJx67lGhVaF4QTFdf9PmjkK
hRzytJ2p5xosa6RfijbNBCOCi2R3Ml+qy85AQDqDnuAHc5Pz2ewNNCM9gqJc9A0x
NzZOnyHmwybjmSdubhSx
=9QDG
-----END PGP SIGNATURE-----

--=-l7pSCQGAdUdnfF2Vp/vD--
