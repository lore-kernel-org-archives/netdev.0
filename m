From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH BUG-FIX] igbvf: fix the bug when initializing the igbvf
Date: Fri, 27 Apr 2012 02:05:39 -0700
Message-ID: <1335517539.2783.89.camel@jtkirshe-mobl>
References: <4F9A5FBC.1060607@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-r9GQSJWbME2vLifz4Zav"
Cc: samuelliao@tencent.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	John Ronciak <john.ronciak@intel.com>,
	David Miller <davem@davemloft.net>, mitch.a.williams@intel.com,
	jpirko@redhat.com, danny.kukawka@bisect.de,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16233 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759919Ab2D0JFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:05:41 -0400
In-Reply-To: <4F9A5FBC.1060607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-r9GQSJWbME2vLifz4Zav
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-04-27 at 16:58 +0800, Shan Wei wrote:
>=20
> From: Samuel Liao <samuelliao@tencent.com>
>=20
>=20
> Maybe it's a typo, but it cause that igbvf can't be initialized
> successfully.
> Set perm_addr value using valid dev_addr, although which is equal to
> hw.mac.addr.
>=20
>=20
> Signed-off-by: Samuel Liao <samuelliao@tencent.com>
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)=20

Thanks Samuel, I will add the patch to my queue.

--=-r9GQSJWbME2vLifz4Zav
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPmmFjAAoJEOVv75VaS+3OgyAP/3XpuMv0befnVK+cpsAExd1Q
AIDJwWwjslH7CyvlfcwCAdlgK23+/qRqSOvKK9BVB8NPeIqRVq1xh+mYux1LoukU
ZfCXl7xummQBRaZYBjFhrRYjX9ZjxmeiMf7ex/T3WZMJOE95KE4/Jnl8ykzd4Hl6
9bI8Z92LiZk4mehfpJmvRuywDOlgBSkGiWI+rj+kfM9jg0w1CHAGwgzueXKY46Pc
v98Z99Uib7f3wYsbImOXbzu4FMrEWkH0YtXD9BumWRUiwsLVOW1tawazFqyTxvjz
CILM3mhskVhGMebz7F9YWYexIftaMt9NawZFS78n9qTJ4rp+eo81gqrzXSQPKLOf
K/YHAjRNYSMys0ft6MM3dVwGxMBgP17IUCKvUNHPcnyKoZyH6FLSj6NPdg51DTum
4PDQk0RGCbaTOdSiglaIFtS8C/VIcu+KxVmXnwjMEF9KTMIQ3ihM814BaXG/cVla
+d26URJKgMG7Na/MMFZXG9tXo1IfNuDeWlCIm/+V2yeSGQR0m9j87hRePQ+CL5Ca
9dSZDGJKnfawUd9HBBIhBvZQER+83APyZcVoVUTp9nb9vKpkl94XvwlXp32PosEF
8Bu2TctjWw3K06k6dzJxkYYRgQaINngHpCQ1+8ULwhi+f9EzqFsKwQUveTidO4r9
WikTUYnXTqh41BWb3+No
=M4z6
-----END PGP SIGNATURE-----

--=-r9GQSJWbME2vLifz4Zav--
