From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH RESEND 7/8] net: xilinx_emaclite: use platform_{get,set}_drvdata()
Date: Mon, 19 Aug 2013 09:09:06 +0200
Message-ID: <5211C492.8060505@monstr.eu>
References: <5208E22C.4090101@huawei.com> <520AFC20.7050006@huawei.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KvGxcBBUEr2V6bdjADDpB86svD6nsDSCU"
Cc: David Miller <davem@davemloft.net>, michal.simek@xilinx.com,
	renner@efe-gmbh.de, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520AFC20.7050006@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KvGxcBBUEr2V6bdjADDpB86svD6nsDSCU
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/14/2013 05:40 AM, Libo Chen wrote:
>=20
> We can use the wrapper functions platform_{get,set}_drvdata() instead o=
f
> dev_{get,set}_drvdata() with &of_dev->dev, it is convenient for user.
>=20
> Also, unnecessary dev_set_drvdata() is removed, because the driver core=

> clears the driver data to NULL after device_release or on probe failure=
=2E
>=20
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

Acked-by: Michal Simek <monstr@monstr.eu>

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--KvGxcBBUEr2V6bdjADDpB86svD6nsDSCU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlIRxJIACgkQykllyylKDCHXMwCfbpJ2lV11A2lpqBK7A6mw9br7
sSgAoIn84jIwKgVfr1jXmn9bYr4jgX+7
=uxKG
-----END PGP SIGNATURE-----

--KvGxcBBUEr2V6bdjADDpB86svD6nsDSCU--
