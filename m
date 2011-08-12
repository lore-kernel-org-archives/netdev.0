From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Thu, 11 Aug 2011 23:08:35 -0700
Message-ID: <1313129316.4588.6.camel@jtkirshe-mobl>
References: <1313120415.2029.3.camel@jtkirshe-mobl>
	 <20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
	 <20110812150003.1e2ba71018bea040fc7649d7@canb.auug.org.au>
	 <20110811.230017.1431877798231142541.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-eD8Nv0QMPU5oqLVv93lX"
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110811.230017.1431877798231142541.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eD8Nv0QMPU5oqLVv93lX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 23:00 -0700, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 12 Aug 2011 15:00:03 +1000
>=20
> > However, Dave, I now get these (powerpc ppc64defconfig build of just th=
e
> > net tree):
>=20
> This should fix the cxgbi scsi problems, I'll work on the mlx4 ones
> next.
>=20
> Thanks.

Dang you beat me to it.  I have the inifiniband fix as well in my patch.

>=20
> From b6a0e86efb79b8ee71cb2129f3ad384d7efc22e3 Mon Sep 17 00:00:00 2001
> From: "David S. Miller" <davem@davemloft.net>
> Date: Thu, 11 Aug 2011 22:59:31 -0700
> Subject: [PATCH] cxgbi: Fix scsi Kconfig dependencies.
>=20
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/scsi/cxgbi/cxgb3i/Kconfig |    3 ++-
>  drivers/scsi/cxgbi/cxgb4i/Kconfig |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/scsi/cxgbi/cxgb3i/Kconfig b/drivers/scsi/cxgbi/cxgb3=
i/Kconfig
> index 11dff23..6bbc36f 100644
> --- a/drivers/scsi/cxgbi/cxgb3i/Kconfig
> +++ b/drivers/scsi/cxgbi/cxgb3i/Kconfig
> @@ -2,7 +2,8 @@ config SCSI_CXGB3_ISCSI
>  	tristate "Chelsio T3 iSCSI support"
>  	depends on PCI && INET
>  	select NETDEVICES
> -	select NETDEV_10000
> +	select ETHERNET
> +	select NET_VENDOR_CHELSIO
>  	select CHELSIO_T3
>  	select SCSI_ISCSI_ATTRS
>  	---help---
> diff --git a/drivers/scsi/cxgbi/cxgb4i/Kconfig b/drivers/scsi/cxgbi/cxgb4=
i/Kconfig
> index d5302c2..16b2c7d 100644
> --- a/drivers/scsi/cxgbi/cxgb4i/Kconfig
> +++ b/drivers/scsi/cxgbi/cxgb4i/Kconfig
> @@ -2,7 +2,8 @@ config SCSI_CXGB4_ISCSI
>  	tristate "Chelsio T4 iSCSI support"
>  	depends on PCI && INET
>  	select NETDEVICES
> -	select NETDEV_10000
> +	select ETHERNET
> +	select NET_VENDOR_CHELSIO
>  	select CHELSIO_T4
>  	select SCSI_ISCSI_ATTRS
>  	---help---



--=-eD8Nv0QMPU5oqLVv93lX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJORMNjAAoJECTsCADr/EWUdwgIAKUwD4R1Fvo0q5uJrevb36w7
fPiQ5zL2lROYTFwZemmoz6hIz2q0LLc0fCE1f6gGvqL3Lm9FlkHbUkyyPUI3t6Eu
zJ3DXja6a1l24CBcJWvFse/CoY0xKM3ljtg0uSWlD2FIgvTZV2K+q+4buOjFVze1
0J7DfDEs/HrY/FwHXqB9rGC+b0Lv///K5hXoyWwc3554qyL8iGWMXvg7pwtrAh8r
95EpBqtii+IVIUuZKBAbk6K+fdjWEdzxPmWn81FWtztpIbi57jYTC3j+NcSXfgXq
sfkmyt/mSk/Xp8SodzfEt5lxJ/7mcD7LcO6ryiAecUVzTqP7qR4vFnFFaSGPE08=
=UYRF
-----END PGP SIGNATURE-----

--=-eD8Nv0QMPU5oqLVv93lX--
