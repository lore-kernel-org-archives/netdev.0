From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: fix mismatch in mutex lock-unlock in
 e1000_reset_hw_82571()
Date: Thu, 18 Apr 2013 23:44:39 -0700
Message-ID: <1366353879.15587.4.camel@jtkirshe-mobl>
References: <1366348518-5594-1-git-send-email-khoroshilov@ispras.ru>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XNn6EdDikOAzvLHf/8sQ"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366348518-5594-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XNn6EdDikOAzvLHf/8sQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-04-18 at 22:15 -0700, Alexey Khoroshilov wrote:
> If e1000_get_hw_semaphore_82574() succeed, it acquires swflag_mutex,
> otherwise it does not. But the returned value of
> e1000_get_hw_semaphore_82574() is ignored, so unlocking of
> swflag_mutex
> happens anyway.
>=20
> The patch fixes the issue by breaking reset if MIC ownership is not
> acquired.
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/ethernet/intel/e1000e/82571.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)=20

Thanks Alexey, I have added your patch to my queue.

--=-XNn6EdDikOAzvLHf/8sQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRcOfXAAoJEOVv75VaS+3OJm8P/j9JlZ1HT88QIs8e0eJDO7hO
qx1+zgLvGZ3vnrWGecWwQVEJ8HUwcPDzwwRjah9Up1ybXhZkVQuVTtxhlylRzLao
H0MdPH5mADbr9oa2JKo5JXgjcpfIUrV+nzYvujylCYHy5ozyHA73EBzRNwB8h8Ci
0jTkpvjqO7Kv2SkYIErc400AGenew6F6cYA2hYujxXc/X2N+GHS/BOi1ImO1mb5L
z9QzDMRNt6u/H/CnPmY/SkQ/xWwmqaLHMHZ696A5rBYhojDj6PNJUgi0JnSql1NM
JaauE7wpsJvuc4dwf9Xditw2FK1aG9bSzygUsogkDaIl8QVZ8Onyur6DuMlF4nfx
qLeK++InEvp7MnUkQcyXSxKMC7IHjTTWQKuGlspfsA3adhzbEvqqHTCyNO8iAc3l
ZKfIwg0WDyMrZpXHk9E236FAEJd5nb1UleA5eQ3fD3A1FBW0TztS88Qm7U2kOFWG
OfCR33J3SFIXRYVLRcTVpaiRCp3vdth+mw2CYG03bGXDLxzMpbVeTw1+A1qlG4Dw
BMc9d6zo/3+NcksB5jiJ+H8D4F8F5+DM0V++qPlaBx5lsrOUyG2HUhICxWPGp09G
25qHL06zKKqvfC94QEjp4X9y1o6usdjz/PeRW9SHX6x8uALRcwVebKMXeHFVKmZy
MllP/4NoOIFEWROdcqlE
=S0ff
-----END PGP SIGNATURE-----

--=-XNn6EdDikOAzvLHf/8sQ--
