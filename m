From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 06 Jun 2012 01:46:06 -0700
Message-ID: <1338972366.10602.48.camel@jtkirshe-mobl>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vxzr18hIuQp+ghxtByc7"
Cc: davem@davemloft.net, denys@visp.net.lb, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29311 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064Ab2FFIqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 04:46:07 -0400
In-Reply-To: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vxzr18hIuQp+ghxtByc7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-06-06 at 17:43 +0900, Hiroaki SHIMODA wrote:
> Denys Fedoryshchenko reported Tx stalls on e1000e with BQL enabled.
>=20
> e1000e has WTHRESH which determines when Tx descripters are written
> back and successive Tx interrupts are generated, and setting WTHRESH
> to 5 gives efficient bus utilization but this cause possible Tx
> stalls,
> especially on BQL enabled system.
>=20
> To avoid possible Tx stalls, change WTHRESH to 1.
>=20
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h  |    6 +++---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)=20

Thanks! I will add this to my queue of e1000e patches.

--=-vxzr18hIuQp+ghxtByc7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPzxjOAAoJEOVv75VaS+3O+bQP/iH3hhK9SwZW/aCWH2O43Yog
Kr1BVBc0LY3ThVLgNd1TVGvuk+diTYiVNaXcSitRNTLgZfcUMdzJVxF66HT7mBPf
StPhAvr0BhGfW+hmO29wonAAetVHQYd+q1lC56cmpUh/cDWkPLbFZa858EjFPqZT
nxEmTzVbgTBXkxtoV/t8dmx/hygY16V9tNYB/QEL6kC9b8hLzwi7i/xBn12I6r8N
yo167AbdkJMU6NqxRiTeTPlVUKnUIIxG2D+iF3tKHkFd5ngVNjBm4g6+j/OB5HYS
UH5iywq00GORxfVNRBCS4D4CPum2mfTui9FQdnuBuQ0/0Nu7cOxmjL3tzaqBazJs
AIdy3y3vP4bswip/i94ttPRXk0ZNi7Ya+czEQdTmFaKV6kIhyLGympGDFTmZGC/u
2luFzPVciBNBfVCCeR7b7lPbxTyiKN31l0Xbv4biO2B7seXKZduZYfAFxKLziFTK
GSLY1j8aHFpjUfPYiyZziesas/i+5DJ+URbJ/JBTsZ19gD5d8jaDYw76p43kH9i7
W9U+uWL42mRdDwy3b9hhY8npOij5SzzCoSDGZU+HmMUG9Lw79C1Tmz6B4CuP5heZ
I/mSyBGVUOk15ItIrHx0FGcyps4+GwjIXIFUOYHvy/eZtRpEYGQRyWZSo4hIm1b4
hkOSD+sVs/Ex3YsBdyHd
=WqZG
-----END PGP SIGNATURE-----

--=-vxzr18hIuQp+ghxtByc7--
