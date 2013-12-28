From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 07/20] net: ixgbe: slight optimization of
 addr compare
Date: Sat, 28 Dec 2013 05:16:24 -0800
Message-ID: <1388236584.2183.192.camel@jtkirshe-mobl>
References: <52BE6CFD.4090403@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-P7tuZEL6HSYBcQ0j9lO6"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BE6CFD.4090403@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-P7tuZEL6HSYBcQ0j9lO6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-28 at 14:17 +0800, Ding Tianhong wrote:
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

Thanks Ding, I will update the patch in my queue with this updated
version.

--=-P7tuZEL6HSYBcQ0j9lO6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvs8oAAoJEOVv75VaS+3OGX4P/RrOfivPqLRPw4STa27SxEMt
bvwbEQ9fGwhT5KZq6tBj8BDvesbXVWx/5niB05Y3QFpp7I26OMMKgPvhefl2n4qw
9SAQd8Ytjsmc4FdZ3md2la0v5iPtHRIcTQXk79uIUrFTOP1xT+3TRgNsHgojZyAw
rxN6NYF4D0Ggb64bAxfRx1VctTE5v7TG65bH1tNp1UItJKU6TxPdWcc3r2aVvxXV
5O5NPNB1XBBkE20LqOwCA10VK+MpZ8E2lXiX4x7ozhOFr9VIXohmcEBf5dp96JML
uPf1JRFedJyWHcRjzV/kaTIsKOs2TX4INxhJ2b4GRGQUarvOXrJwchE6bKbAJkTL
TRV0ozGNQsar7tG1scidIKIgPTLOnL8+Ts05jqt2sWCfAhisUKiNjD9lIFo/A93k
AGWPeOXa35lxhQtLh5FqDYJNXwXpPWFCaCP26Bmiw/SdvEa6NkH1n0HjV+S0o29X
WQtWDNdFgedilvgXMvYVqq3JSISz1r+Ykbixeb+LcZrGeQgRLU/5V93jE3idz+Xs
A216dgxrPySDHD+DINarR8CSBgJTFyyjmlvHQwYlR6PDaIRUr0lT5umt0oRieFJ0
vMbGRvNPMzPwOLx897dRvE2lAi21sW7KvBauS66J2VTVuh/lLeg4yYPeRnkFU4K/
Z3ELDDHGD8r5s949KfWI
=ykeH
-----END PGP SIGNATURE-----

--=-P7tuZEL6HSYBcQ0j9lO6--
