From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v3] net: macb: Add big endian CPU support
Date: Thu, 26 Feb 2015 12:49:07 +0100
Message-ID: <54EF0833.60600@monstr.eu>
References: <54EEF9C6.8070701@monstr.eu> <1424948474-11872-1-git-send-email-achandran@mvista.com> <54EEFE50.9050002@atmel.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DE6SgTB7VK0SLmLWRjO2oILm9xuQGpCRr"
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Arun Chandran <achandran@mvista.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54EEFE50.9050002@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DE6SgTB7VK0SLmLWRjO2oILm9xuQGpCRr
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/26/2015 12:06 PM, Nicolas Ferre wrote:
> Le 26/02/2015 12:01, Arun Chandran a =E9crit :
>> This patch converts all __raw_readl and __raw_writel function calls
>> to their corresponding readl_relaxed and writel_relaxed variants.
>>
>> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
>> when the CPU is configured in big endian mode.
>>
>> Signed-off-by: Arun Chandran <achandran@mvista.com>
>=20
> It seems okay:
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Tested on Zynq zc702 on LE and BE.

Tested-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--DE6SgTB7VK0SLmLWRjO2oILm9xuQGpCRr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlTvCDMACgkQykllyylKDCFLpwCeMDknOIk7YZuFHPML+ehM4Yek
0wcAoISF4BqrDtipPk/vwE/sdzM3Kqyi
=sa2D
-----END PGP SIGNATURE-----

--DE6SgTB7VK0SLmLWRjO2oILm9xuQGpCRr--
