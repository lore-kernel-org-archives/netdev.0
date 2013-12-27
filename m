From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 06/20] net: igbvf: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 01:48:50 -0800
Message-ID: <1388137730.2183.150.camel@jtkirshe-mobl>
References: <52BD22BB.1060705@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GELYHPrkvNWXAN8A6tnj"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BD22BB.1060705@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GELYHPrkvNWXAN8A6tnj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-12-27 at 14:48 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> to instead of memcmp.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Ding, I have added this patch to my queue.

--=-GELYHPrkvNWXAN8A6tnj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvU0CAAoJEOVv75VaS+3OZuUQAISVBZDuB5c8cglWGd5t7s6F
d204sporr2TSL6pUSIJn5mxJHnHhUSYt5QM9Wu77lRzc/HIjIqCzaO3I11OCA5FW
tFdT4YG7ctC+uTwKY8KaHFy0bev7tRkk6ySUIbMzknuAbbJClhj0x2FMDpyFJCvB
8MSfsMVXH5Kblu6l5iBf+ZdZ7eF8XQ/6CGby27TlWjo/toxQo+iyam4yie2Xr6U1
c3tZCDwHdE9Wi4awJrhKt+MakeuF0HiatvZDvnUgWgzYfc/yKnHyFcS25qolU7JP
pRsYMI91Rm80+eMEI1neyD2DHGRlT4OYxC8QBCFdmsdQhg5mxC/qxGuVkLEvJ4oL
9XmfD1fqguSIOYeEGqt5qVk0xMyEtr5tT/A2zbQIPGGxrxCHwnaP5M9NsBfMRBmS
EPCzGxR8EK3i9dQ2BHXRmj1m8/vw6r/Kvr4JfWlVAz182UfNv5+vX8ghdPw7yaBp
S3Gzgd0VuoNI2peX84nDrJH5mKPpLrXYdkTZS3WSuad9L7n3tn7KMERIg1O+Maqq
fCDn3wp6HnkY6VbKZ3cXRJslamQ2uzWSnE4IeLFmrHmlA84VOk0EcXmsM124o8mM
07gcbvnCSPa2DkMzOdXQkVqPzm8yPwoCqaeu3J1EeyGeKMTaecJyAeqjuKNEgaqQ
nQ3qvMMkv4ZskmD1pfOM
=T00M
-----END PGP SIGNATURE-----

--=-GELYHPrkvNWXAN8A6tnj--
