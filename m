From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3] e1000: ethtool: Add missing dma_mapping_error-call
 in e1000_setup_desc_rings
Date: Tue, 19 Mar 2013 17:47:24 -0700
Message-ID: <1363740444.2069.51.camel@jtkirshe-mobl>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1363429925-12724-2-git-send-email-christoph.paasch@uclouvain.be>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jnUyYApqHlZrvgh2Lc96"
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12976 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756957Ab3CTAr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 20:47:26 -0400
In-Reply-To: <1363429925-12724-2-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jnUyYApqHlZrvgh2Lc96
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-03-16 at 11:32 +0100, Christoph Paasch wrote:
>=20
> After dma_map_single, dma_mapping_error must be called.
>=20
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)=20

Added to my e1000 patch queue

--=-jnUyYApqHlZrvgh2Lc96
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRSQccAAoJEOVv75VaS+3OGlsP/1Vlra+f5XqjCbnYPctlnm0K
/EJRYz0EkAUEMFlieWkIjr6LYa2+jxCEzTb3cHYaamjIF8ZWF7LY6g7qUePyQwWw
gXJHfFetrAWA4aaoFAmLov+UGKvewa+oAzbgxXj0LCAfXn8mn+SLRsMayleG+uNr
9I1gKJphw60VcOT8rtjzY9O7YGxECCuRqDdQUID8Xpe0aqlNC71kbOZkCY89v6JN
KL4xXfk38pW+ABrkOVoygVpLzBnOdzXhlNMKpHnIB04VkCwy51oUEi2XG1a+DNhp
x2Njz+YFWIo9x3PnCDkbcjWJP5Df7ok/QeI+LK0dsLpB6h5Kcvs8UE15Y0QHe4WM
66hoxM/OH3gUzrgbZ2qebsV+jUKTQnTw1KklStw0vmxlppZJnidWqxfdDUPKCSaM
797FsvuASTivtRSEUCxYsNIFQTK8K9ASyaibIlkIpfdWoZkFPpT8dJBLOKLwRTw2
hytslznfWKjFkTOzJnLfw7aXcSqC+KSUHV2RSTbFAPBL6tpfV7mqtV0RTHqe3i8C
OmXN56IV1ic1XVBT5UjnrVHo1BpqvA4PXC3e+i4lJoj+CULQGPkI5ergFlc7kKNu
+ytU7+GUZ485YKu7vHGtK3YvTV46hXp4xlhp06DkQNwc0W9NQ65fHPBOc2Lilh0L
ZMv/d+3Nze0mINvP6Prb
=gKKF
-----END PGP SIGNATURE-----

--=-jnUyYApqHlZrvgh2Lc96--
