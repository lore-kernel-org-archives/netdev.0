From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 07/20] net: ixgbe: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 01:49:03 -0800
Message-ID: <1388137743.2183.151.camel@jtkirshe-mobl>
References: <52BD22BF.70108@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0jDMcv8i2aUI0N+A8kzu"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BD22BF.70108@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0jDMcv8i2aUI0N+A8kzu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-12-27 at 14:48 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> to instead of memcmp.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Thanks Ding, I have added this patch to my queue.

--=-0jDMcv8i2aUI0N+A8kzu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvU0PAAoJEOVv75VaS+3Oi9wP/jSFVgwDTUbJH7HX+zKbGgGr
ZNgd+2iJXABOTh3pCgizF+rKzIQVaLuk4S6Vn8SkSx12tugxMMoPt5C7d7zQOzMD
lrpO7hGjMG+JHPaJCQWOVli200jUO+9zQYTKCBmzs5pCoGAwy3pwO7Zq67o/wBNU
lwDGdBxyatk2hIcMCzlW9mQluosS/TgLy3VfXP4x6nIFx4lwbjCZ613c43qqiqSh
BmhcE/3iTDgouT+gwLjEKvmLG19yEdzDedQ2SK7jSZg43Qcrmm3iu8QM35DMvRmQ
w9I7uWw99MuCiRf9MAe+iYiVoaPign/5rEm2+Cwi6AIpw57JDmcN/kGXZHEuddYx
M+dBuq4diJoGzOjfSwj6PCzksFJtpHZwu+uu9sBxkhPl5ELkjHY+6ISbauHI+Xy/
757CNWUQLSW0BCoDm09/BiEZOZssaf9p+Gm0hU4O/4JnbEMFCG2b2mZIxPnbJgF9
nRcCiZ/WmzlsVkaIiIzzVhTbSFr6WtoAyPSmKfzSCNfbvRE5dtClgau0ZHEuU5Cs
sGWzTPW8hIqfeiwndr8rvwwbYRSg+GOXLF4IpMZfsSXoR6QGls8Fv/9/iSCt62UI
OQeyvUFKx63R2sA2AG3Pk6jjGMcZ9GMB5pGuoJrXQ6CndECGTF8CRIhyfvqHoV2e
p8L/lfXstboSAVi+7HjZ
=SxhN
-----END PGP SIGNATURE-----

--=-0jDMcv8i2aUI0N+A8kzu--
