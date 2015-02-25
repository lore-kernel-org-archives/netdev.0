From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: avoid incorrect ioremap/iounmap sequences for
 e1000_pch_spt
Date: Wed, 25 Feb 2015 13:24:13 -0800
Message-ID: <1424899453.2622.2.camel@jtkirshe-mobl>
References: <1424891492-2897-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FheblL/ks9zz2B2/waB6"
Cc: netdev@vger.kernel.org, David Ertman <david.m.ertman@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:37946 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbbBYVYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 16:24:14 -0500
In-Reply-To: <1424891492-2897-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FheblL/ks9zz2B2/waB6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-25 at 14:11 -0500, John W. Linville wrote:
> Commit 79849ebc0e06 (e1000e: initial support for i219) overwrites
> hw->flash_addr for e1000_pch_spt MACs without doing an iounmap.
> It also reuses the address without changing the areas that then
> iounmap the new address (which was never explicitly ioremap'ed).
> This causes iounmap to spit-out a call trace on rmmod.
>=20
> This patch circumvents this issue on the early hardware that we have
> in-house at Red Hat.
>=20
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: David Ertman <david.m.ertman@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)

Thanks John, your patch has been added to my queue.

--=-FheblL/ks9zz2B2/waB6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU7j19AAoJEOVv75VaS+3OLO0P/itimKQCAcwmKCmsgOvL2jkB
VJkCbpojItUaV8iP432f8983IZJd3DcK+sh3ANJ2DDMTCHtasM7goDb4gIhDvGuF
tKG4R21Y+kvSx22NntJA+kCpqz9XVj3CwU+RP+gqfDQ4jeaVcWDTqg2+0teotvng
Pj+JRqqJZLUQ6qWt5dnk2QrWikUCv8QHShJPWLDvcXXy5tXFMAzfunmqpTX+eev1
p16uVmquB/oCuERBhOOfIrogNPvV0Y8C+WygVyvkINUHpHQF8KC+QjR1D4M1HsAE
9m+llnIngs3mpHyZUmYiofyzUZtB7U2IP0o5T5wyPPFLBYCncObGA4j6Vc0Apre6
2Is8Btbn6v/WbdJdPKdUYmpwz2KYk9e5ebPSNc5FxdguguqtJ6PK6oJ6RnSqlIQb
kSKNA8SYU5rOzT1QcRuSODGJK/ZWqlnvudNv8V4pFhvb+4HG6atCYWZTh7uvC6+9
MMROiSWFmb1BWA1ap6JJou1hdK/sXmgc0l2H5QXB0eo2Eqd2uy2kPKElyMrAlONj
jZIkQDU59p5OJFXrEgRJVgQc9h1m8ONo/JvkLTqGiavNsVn9eLb9rWOHcx/oi7DW
2bBwKOt/Ko+baknjY6c0vpwYMRid7IYSjOfrqnin/4ngWVF7+pK8pIjq0gUg9pxz
aHarsBcr+b2loStTHHMb
=9wZd
-----END PGP SIGNATURE-----

--=-FheblL/ks9zz2B2/waB6--
