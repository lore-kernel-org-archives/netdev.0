From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 1/2] net: macb: Include multi queue support for xilinx
 ZynqMP ethernet version
Date: Thu, 05 Mar 2015 15:00:17 +0100
Message-ID: <54F86171.3020700@monstr.eu>
References: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="BnXrihX075659nMVOGOxMv9OmsI0LvNT5"
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BnXrihX075659nMVOGOxMv9OmsI0LvNT5
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Nicolas,

On 03/05/2015 02:04 PM, Michal Simek wrote:
> From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
>=20
> Include multi queue support for the ethernet IP version in xilinx ZynqM=
P
> SoC.
>=20
> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> ---
>=20
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
> index ad76b8e35a00..24b1eb466e52 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2192,7 +2192,7 @@ static void macb_probe_queues(void __iomem *mem,
> =20
>  	/* is it macb or gem ? */
>  	mid =3D __raw_readl(mem + MACB_MID);
> -	if (MACB_BFEXT(IDNUM, mid) !=3D 0x2)
> +	if (MACB_BFEXT(IDNUM, mid) < 0x2)
>  		return;
> =20
>  	/* bit 0 is never set but queue 0 always exists */
>=20

Can you please check this?
(There will be definitely v2 because I forget to base it on net-next).

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--BnXrihX075659nMVOGOxMv9OmsI0LvNT5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlT4YXEACgkQykllyylKDCEqvQCeORnCxrqMMCXYPPOpiS4F0///
UhUAn1b5OCHeG3iEfzyNaNaLjA6iwdgl
=BFaQ
-----END PGP SIGNATURE-----

--BnXrihX075659nMVOGOxMv9OmsI0LvNT5--
