From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 7/8] net: xilinx_emaclite: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 15:28:12 +0200
Message-ID: <5208E2EC.8050106@monstr.eu>
References: <5208E22C.4090101@huawei.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KUDqQuPKPGUVCDmomxEaLrrq30iKQO0fu"
Cc: David Miller <davem@davemloft.net>, michal.simek@xilinx.com,
	renner@efe-gmbh.de, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E22C.4090101@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KUDqQuPKPGUVCDmomxEaLrrq30iKQO0fu
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/12/2013 03:25 PM, Libo Chen wrote:
>=20
> Use the wrapper functions for getting and setting the driver data using=

> platform_device instead of using dev_{get,set}_drvdata() with &pdev->de=
v,
> so we can directly pass a struct platform_device.
>=20
> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/ne=
t/ethernet/xilinx/xilinx_emaclite.c
> index fd4dbda..4c619ea 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1230,8 +1230,7 @@ error:
>   */
>  static int xemaclite_of_remove(struct platform_device *of_dev)
>  {
> -	struct device *dev =3D &of_dev->dev;
> -	struct net_device *ndev =3D dev_get_drvdata(dev);
> +	struct net_device *ndev =3D platform_get_drvdata(of_dev);
>=20
>  	struct net_local *lp =3D netdev_priv(ndev);
>=20
> @@ -1250,7 +1249,6 @@ static int xemaclite_of_remove(struct platform_de=
vice *of_dev)
>  	lp->phy_node =3D NULL;
>=20
>  	xemaclite_remove_ndev(ndev, of_dev);
> -	dev_set_drvdata(dev, NULL);
>=20
>  	return 0;
>  }
>=20

Acked-by: Michal Simek <monstr@monstr.eu>

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--KUDqQuPKPGUVCDmomxEaLrrq30iKQO0fu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlII4u0ACgkQykllyylKDCGMwgCeIqpETSseY5FO1pvWk382rjF5
IkkAoJq8g9oE3mH/AlV7neMwv9n6m9hq
=Ojw7
-----END PGP SIGNATURE-----

--KUDqQuPKPGUVCDmomxEaLrrq30iKQO0fu--
