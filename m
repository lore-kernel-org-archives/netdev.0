From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 22/52] net: e100: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 01:39:51 -0700
Message-ID: <1378888791.2026.2.camel@jtkirshe-mobl>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
	 <006001ceaec2$f0ef0dd0$d2cd2970$%han@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-93nN95rI6r+rGLzoISQ2"
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'Aaron Brown' <aaron.f.brown@intel.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31413 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979Ab3IKIkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 04:40:07 -0400
In-Reply-To: <006001ceaec2$f0ef0dd0$d2cd2970$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-93nN95rI6r+rGLzoISQ2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-09-11 at 16:45 +0900, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
>=20
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>  drivers/net/ethernet/intel/e100.c |    2 --
>  1 file changed, 2 deletions(-)

While I do not find anything wrong with this patch, I personally like
good housekeeping so I would like to keep the code as is.  Is there a
reason for this patch?

--=-93nN95rI6r+rGLzoISQ2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSMCxXAAoJEOVv75VaS+3OHzoQAJ5LpyyMvq6o4I2zBJXy32Vp
2rTjclYDMxqSgCC5QL/j+SMm0s0fInWjndtlO+vy5+70AvQVcekLvzv28ycjGzlf
KHWF6DlbksFgxF8us3sxzJvU0SN1YStgGPxvc2F9Y+Iu1CcXssIpOla1Dc3ZfRiB
X7g37afkBGgZHmiGkZ3CYa+8qKVupv+/PkPSO1kQPvD4N1tRiM+GKcIFMRuZ6tpQ
JUjffx0aQE02E5j6pyJ56OUU3rUUn/QzOt3nuPhRqmHJ7oH2kzxJYJ95p9fxCB1C
D0KbeW5NmbDe3MJYPPzL0aHWZ0gF2iCR7OF21+Evy2SyLd/UIwOg5wJsXgaONX6i
5+9aM/1Prb1PNJPvjnX2JLKrVPSRR5Y92YUoKhPcEKiWQimLquIY+sqGxBDBSLt0
u/vXBSiy5zDCdekMShxtdEP6N+Vw9sw/3d1GPVG2ECsPrfEFwjb9rGOCz3puIrAN
fqwP6FAsVgl+aR6Fjycwk9GgSqj3DYAgHAaiRrzRfg5MDt7npxlWVjgn/1fc+15O
HVy56LKi4MJIetM8244OB65gbo8cb91sG/v5oG5cttvUoyMQLXTbsdU1nsuJkKO9
+/OoQecu40Er7GfkR0aAJnla5BJLetIJEuDFLf49meEqYGNj8Z6elmyqzbD8ATVx
qKSrh/s/K0D/8El3K6Po
=JbFR
-----END PGP SIGNATURE-----

--=-93nN95rI6r+rGLzoISQ2--
