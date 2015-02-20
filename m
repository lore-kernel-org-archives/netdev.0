From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: Fix memory leak at failure path in
 i40e_dbg_command_write()
Date: Fri, 20 Feb 2015 15:28:39 -0800
Message-ID: <1424474919.2979.41.camel@jtkirshe-mobl>
References: <1424471058-19933-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DuEDB1s7urcCyczE4ZBI"
Cc: Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424471058-19933-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DuEDB1s7urcCyczE4ZBI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-02-21 at 01:24 +0300, Alexey Khoroshilov wrote:
> The patch fixes a leak of 'cmd_buf' when copy_from_user() failed
> in i40e_dbg_command_write().
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Thanks Alexey, I have added your patch to my queue.

--=-DuEDB1s7urcCyczE4ZBI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU58MnAAoJEOVv75VaS+3OdFQP/i+od8WydjN4gQGWptjIcael
S5tp8TX0jd8uqFhkHyckd1Ztog92GtRWbwon39jGQDU/DsmqWLmS0JTJY3VV1jpT
siA/X0wlQsq+H1j/aAoyFkM2dliEp+O4nDBb94BFdtj9DD3FRArMPgNdyByIvVZz
ZJKJ+aEIBlDIKpj0gD/EgpIH/O2Xc+ZHK2w1cCkmYqO9jpbvt7Ymfr9UQW1xsY2o
r58C1m3lNJfSWuVPJcsHoBNXGCdKGKIVIXASj7iV4xoJRo6NG324hRJ1uv75TDEU
gXTTZZO2fgCuvO9BYruS/mNqyJK+WY7RVtgTavlu1IV9pK5Ew82yxaLDopdaEHdW
/g9S3tTSkF4H6WC0FDankEpyVzeRJEQ684Spe889UYvR/yV9wo6KpPL/E3bRcDXN
xO1nLGPoJC9G90fNS+MzAos0rxcuWmFsY6fqv9TYKs51qRwl2Fw0arbrgIW3MRYB
kpG84jbJ1R/Iu0TYvFhAJQ3rivHzvXPeY+7A+ZkahME32MCqDeVzH3zBZ+GGgRdI
yk+juFfaSeYOHw3/bGQmM4M3PPMG19TE0njoxGD5mjg+tS/ZGBn4t8OlBC4ngJxq
uS8+gsy8eBDKQkBiKmKy/ysd1y2+iFxJUQ+hxHVJrR5LfpxOFzfTCZ/yIti1rhdR
uC3NBt+wIKzuO8j3PSp9
=X5El
-----END PGP SIGNATURE-----

--=-DuEDB1s7urcCyczE4ZBI--
