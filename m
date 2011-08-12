From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Thu, 11 Aug 2011 23:11:50 -0700
Message-ID: <1313129511.4588.8.camel@jtkirshe-mobl>
References: <20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
	 <20110812150003.1e2ba71018bea040fc7649d7@canb.auug.org.au>
	 <20110811.230017.1431877798231142541.davem@davemloft.net>
	 <20110811.230552.837691497153518712.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-anUmtX0drPvIvaXSc7Y9"
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110811.230552.837691497153518712.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-anUmtX0drPvIvaXSc7Y9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 23:05 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 11 Aug 2011 23:00:17 -0700 (PDT)
>=20
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Fri, 12 Aug 2011 15:00:03 +1000
> >=20
> >> However, Dave, I now get these (powerpc ppc64defconfig build of just t=
he
> >> net tree):
> >=20
> > This should fix the cxgbi scsi problems, I'll work on the mlx4 ones
> > next.
>=20
> And this one will fix the mlx4 infiniband problems, thanks Stephen.

Are you working on the cxgb3/4 infiniband errors as well?  The fix is
similar to the fix below.

>=20
> --------------------
> From af3dcd2f449b7243a4c7b987125ffc40fad262f0 Mon Sep 17 00:00:00 2001
> From: "David S. Miller" <davem@davemloft.net>
> Date: Thu, 11 Aug 2011 23:05:05 -0700
> Subject: [PATCH] mlx4: Fix infiniband Kconfig dependencies.
>=20
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/infiniband/hw/mlx4/Kconfig |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/infiniband/hw/mlx4/Kconfig b/drivers/infiniband/hw/m=
lx4/Kconfig
> index bd995b2..24ab11a 100644
> --- a/drivers/infiniband/hw/mlx4/Kconfig
> +++ b/drivers/infiniband/hw/mlx4/Kconfig
> @@ -1,6 +1,7 @@
>  config MLX4_INFINIBAND
>  	tristate "Mellanox ConnectX HCA support"
> -	depends on NETDEVICES && NETDEV_10000 && PCI
> +	depends on NETDEVICES && ETHERNET && PCI
> +	select NET_VENDOR_MELLANOX
>  	select MLX4_CORE
>  	---help---
>  	  This driver provides low-level InfiniBand support for



--=-anUmtX0drPvIvaXSc7Y9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJORMQmAAoJECTsCADr/EWUSssIAJbTaj8zqBW3usxDJGvRlfs8
mo2l1INEQepqdJ7nQALM0WBABAyw6YdyE+X689G1xcLrpJpdSrgs8yZnGSzdbGWk
BlmdC1VlPlTSX7Ji/3em8UEA2QWG5hOyjeDkWtKo5C/O+p9RPAogZfgg40o7ikCC
CmVf88z+5dno4E5+OoJZv4aGj4w5dbiH42ut7z9RXkRRbX3X3VibH3vl+v4a9aiS
EyRGS9Codnd79ch0XVFPiBEa/BQEV9ilOOf6Qae8cJGxpBugVrChAbw5oNsRV+Ft
DsdfEPXJM+IJ9pYprpUQ0h0u8GX5X29ka1N2fH0M37XIP7U0hjn9c34Ocw6Afzw=
=lNqE
-----END PGP SIGNATURE-----

--=-anUmtX0drPvIvaXSc7Y9--
