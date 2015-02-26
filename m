From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Thu, 26 Feb 2015 11:47:34 +0100
Message-ID: <54EEF9C6.8070701@monstr.eu>
References: <54ED9DA8.3040809@monstr.eu> <1424947454-11776-1-git-send-email-achandran@mvista.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uGo9CJxMcqM1DHK9qhX3Waw6CD57D4PsG"
To: Arun Chandran <achandran@mvista.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424947454-11776-1-git-send-email-achandran@mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uGo9CJxMcqM1DHK9qhX3Waw6CD57D4PsG
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Arun,

On 02/26/2015 11:44 AM, Arun Chandran wrote:
> This patch converts all __raw_readl and __raw_writel function calls
> to their corresponding readl_relaxed and writel_relaxed variants.
>=20
> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
> when the CPU is configured in big endian mode.
>=20
> Signed-off-by: Arun Chandran <achandran@mvista.com>
> ---
> 	This patch is tested on xilinx ZC702 evaluation board with
> 	CONFIG_CPU_BIG_ENDIAN=3Dy and booting NFS rootfs
> 	Added on the fly IP endianness detection according to
> 	comments from Michal Simek.
> 	Corrected GEM_* macros as per comments from Nicolas Ferre
> ---
> ---
>  drivers/net/ethernet/cadence/macb.c | 32 ++++++++++++++++++++++++++---=
---
>  drivers/net/ethernet/cadence/macb.h | 18 ++++++++++--------
>  2 files changed, 36 insertions(+), 14 deletions(-)
>=20

Can you please send regular v3 and list all changes you have done?

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--uGo9CJxMcqM1DHK9qhX3Waw6CD57D4PsG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlTu+cYACgkQykllyylKDCFdtQCgmtJRS9gV4U2h8zn+Q5aCdSDF
3wkAn3qHjw2/9z0w4YrP6nr/wcUjD1yk
=BePu
-----END PGP SIGNATURE-----

--uGo9CJxMcqM1DHK9qhX3Waw6CD57D4PsG--
