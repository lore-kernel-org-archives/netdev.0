From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] net: emaclite: Fix typo in error message
Date: Tue, 04 Jun 2013 12:27:21 +0200
Message-ID: <51ADC109.5050000@monstr.eu>
References: <51AB626A.3040809@efe-gmbh.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2AQAKDCRBSSPLCEVHHWCE"
Cc: netdev@vger.kernel.org
To: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:60298 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab3FDK1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 06:27:24 -0400
Received: by mail-wg0-f48.google.com with SMTP id f12so28331wgh.15
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 03:27:23 -0700 (PDT)
In-Reply-To: <51AB626A.3040809@efe-gmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2AQAKDCRBSSPLCEVHHWCE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/02/2013 05:19 PM, Jens Renner (EFE) wrote:
> s/allocal/allocate/
>=20
> Signed-off-by: Jens Renner <renner@efe-gmbh.de>
> ---
> Changes in v2:
> - fix whitespace problem
>=20
> drivers/net/ethernet/xilinx/xilinx_emaclite.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/ne=
t/ethernet/xilinx/xilinx_emaclite.c
> index aa14d8a..aaadf7e 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -877,7 +877,7 @@ static int xemaclite_mdio_setup(struct net_local *l=
p, struct device *dev)
> =20
>  	bus =3D mdiobus_alloc();
>  	if (!bus) {
> -		dev_err(dev, "Failed to allocal mdiobus\n");
> +		dev_err(dev, "Failed to allocate mdiobus\n");
>  		return -ENOMEM;
>  	}

I have checked that it is not corrupted by email client
and
Acked-by: Michal Simek <monstr@monstr.eu>

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2AQAKDCRBSSPLCEVHHWCE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGtwQkACgkQykllyylKDCFQ4ACfUptnquvGiIDEE1EIfGE1cSdV
NMwAnAsodZyprE1FQK+1GMWkTNsP6JQj
=E/QA
-----END PGP SIGNATURE-----

------enig2AQAKDCRBSSPLCEVHHWCE--
