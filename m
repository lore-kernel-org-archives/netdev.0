From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 6/8] net: xilinx_emaclite: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 09:21:18 +0200
Message-ID: <52146A6E.5030005@monstr.eu>
References: <1377068556-51316-1-git-send-email-libo.chen@huawei.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xqFx5DVG6V3hTOUi59ffxortln8LoO1oW"
Cc: davem@davemloft.net, michal.simek@xilinx.com, renner@efe-gmbh.de,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lizefan@huawei.com
To: Libo Chen <libo.chen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:55519 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab3HUHVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 03:21:25 -0400
Received: by mail-ea0-f177.google.com with SMTP id f15so33982eak.8
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 00:21:24 -0700 (PDT)
In-Reply-To: <1377068556-51316-1-git-send-email-libo.chen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xqFx5DVG6V3hTOUi59ffxortln8LoO1oW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/21/2013 09:02 AM, Libo Chen wrote:
> Unnecessary dev_set_drvdata() is removed, because the driver core
> clears the driver data to NULL after device_release or on probe failure=
=2E
>=20
> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/ne=
t/ethernet/xilinx/xilinx_emaclite.c
> index 7c1ccbc..4c619ea 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1249,7 +1249,6 @@ static int xemaclite_of_remove(struct platform_de=
vice *of_dev)
>  	lp->phy_node =3D NULL;
> =20
>  	xemaclite_remove_ndev(ndev, of_dev);
> -	dev_set_drvdata(dev, NULL);
> =20
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



--xqFx5DVG6V3hTOUi59ffxortln8LoO1oW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlIUam4ACgkQykllyylKDCEaVwCfYNvW/3LNhul7Mkxo5Ik2IcYd
rxwAnROcyW876sL3Z7AAanhqV2hzqnwQ
=hZmA
-----END PGP SIGNATURE-----

--xqFx5DVG6V3hTOUi59ffxortln8LoO1oW--
