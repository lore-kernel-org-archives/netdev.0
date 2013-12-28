From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 06/20] net: igbvf: slight optimization of
 addr compare
Date: Sat, 28 Dec 2013 05:15:38 -0800
Message-ID: <1388236538.2183.190.camel@jtkirshe-mobl>
References: <52BE6CF8.5030806@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-t0/fUJ7RPWcAN+vVqjrS"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BE6CF8.5030806@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-t0/fUJ7RPWcAN+vVqjrS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-28 at 14:17 +0800, Ding Tianhong wrote:
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

Thanks Ding, I will update the patch in my queue with this updated
version.

--=-t0/fUJ7RPWcAN+vVqjrS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvs76AAoJEOVv75VaS+3OF7QQAJGjxd5i76w3ja7dL0WlwhY5
f3F834YSKZrhTq1jtISnKzkt5eseqylvEyftoAblGm+CG+kUzI8spLzTvySfPdLY
hri+Qfg9q7xNoiKdcbgP1/mZ3G0jpqh/lGq6Mni8S+G6XtjRFUIm8pgWiH1Q+KQ2
++33SKVM5ffO/yCyLwMtys+/SlvhvtzMFuW1nEqBk2okG07o8i5vgE60L57azm/p
ndQsK7ZGbkBwX/9kJfzCJXIxUAM+O7j1xdt006PKhiSkmDNVUlK/wjqfY7dWJuex
VCCwUf1KBZacz2mC8ENM0uvqmzIQyxq6cRO021EmbOqBFWvHgUHOI5Poa3qxhADh
DHmKYaIEURiilpSOT2CkYF/T/RdEjQxZlIUDrjKbYOJD5xt8bIB+b9AhWZ5LC0ms
Th6jJOoB0S35Vo2r5ZHh1gjbsqmdBgsp2VyC4FOrafM+5FzkhUpC9acezYBV/9qt
z9XAmrQg+sPEKf0nDLlHgwxDi6UTvOsZEQZC7oYLDDO+fiF4ULgJfJpmuSZV29Q9
zsekBrjwvR/FMOMhFTGLaEPzxXxLmgcb+XSwS1AnZOssXGTr0zIocAxxnv5Ul9gc
EsIh6jzEoRNXkOpy7CAuz4DceUxKDpXQHzTATDclSUQX7YBj5fMLV1qg1jdiGCBG
hKpBwQQRGmirEGoydCfm
=GMLg
-----END PGP SIGNATURE-----

--=-t0/fUJ7RPWcAN+vVqjrS--
