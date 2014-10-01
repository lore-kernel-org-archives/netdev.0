From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: xilinx: Remove unnecessary ether_setup after alloc_etherdev
Date: Wed, 01 Oct 2014 10:25:37 +0200
Message-ID: <542BBA81.2000406@monstr.eu>
References: <d43b465eca3e2a53c930f6e02dc4ac8b3c084693.1412143216.git.michal.simek@xilinx.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="2d9c4B3TCV7M7xxxsgIWtuEnsPUi7sq3T"
Cc: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?windows-1252?Q?Manuel_Sch=F6lling?= <manuel.schoelling@gmx.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	Joe Perches <joe@perches.com>,
	Ricardo Ribalda <ricardo.ribalda@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d43b465eca3e2a53c930f6e02dc4ac8b3c084693.1412143216.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2d9c4B3TCV7M7xxxsgIWtuEnsPUi7sq3T
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/01/2014 08:00 AM, Michal Simek wrote:
> From: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>
>=20
> Calling ether_setup is redundant since alloc_etherdev calls it.
>=20
> Signed-off-by: Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> ---
>=20
>  drivers/net/ethernet/xilinx/ll_temac_main.c       | 1 -
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 1 -
>  2 files changed, 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/=
ethernet/xilinx/ll_temac_main.c
> index fda5891835d4..629077050fce 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -1012,7 +1012,6 @@ static int temac_of_probe(struct platform_device =
*op)
>  	if (!ndev)
>  		return -ENOMEM;
>=20
> -	ether_setup(ndev);
>  	platform_set_drvdata(op, ndev);
>  	SET_NETDEV_DEV(ndev, &op->dev);
>  	ndev->flags &=3D ~IFF_MULTICAST;  /* clear multicast */
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/driver=
s/net/ethernet/xilinx/xilinx_axienet_main.c
> index c8fd94133ecd..4ea2d4e6f1d1 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -1485,7 +1485,6 @@ static int axienet_of_probe(struct platform_devic=
e *op)
>  	if (!ndev)
>  		return -ENOMEM;
>=20
> -	ether_setup(ndev);
>  	platform_set_drvdata(op, ndev);
>=20
>  	SET_NETDEV_DEV(ndev, &op->dev);
> --
> 1.8.2.3
>=20

Please ignore this one it is already applied for axienet.
Will send v2 just for ll_temac.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--2d9c4B3TCV7M7xxxsgIWtuEnsPUi7sq3T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlQruoEACgkQykllyylKDCEBhgCeKHPc4szkECMN7UaTpzIfaagJ
bBoAoIIJo7dEEsMYXwWY+rPFWah4YB9X
=N+Nd
-----END PGP SIGNATURE-----

--2d9c4B3TCV7M7xxxsgIWtuEnsPUi7sq3T--
