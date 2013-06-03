From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v3] net: ethernet: xilinx_emaclite: set protocol selector
 bits when writing ANAR
Date: Mon, 03 Jun 2013 11:38:26 +0200
Message-ID: <51AC6412.5090202@monstr.eu>
References: <51AB6680.7010507@efe-gmbh.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2EHHHDGUVAVNHRTRWDHTB"
Cc: netdev@vger.kernel.org
To: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:54177 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab3FCJik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 05:38:40 -0400
Received: by mail-wi0-f181.google.com with SMTP id hi5so2446067wib.14
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 02:38:39 -0700 (PDT)
In-Reply-To: <51AB6680.7010507@efe-gmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2EHHHDGUVAVNHRTRWDHTB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/02/2013 05:36 PM, Jens Renner (EFE) wrote:
> This patch sets the protocol selector bits (4:0) of the PHY's MII_ADVER=
TISE
> register (ANAR) when writing ADVERTISE_ALL. The protocol selector bits =
are
> indicating IEEE 803.3u support and are fixed / read-only on some PHYs. =
Not
> setting them correctly on others (like TI DP83630) makes the PHY fall b=
ack
> to 10M HDX mode which should be avoided.
>=20
> Tested for TI DP83630 PHY on Microblaze platform.
>=20
> Signed-off-by: Jens Renner <renner@...-gmbh.de>

You should probably fix this line too.

Thanks,
M

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2EHHHDGUVAVNHRTRWDHTB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGsZBMACgkQykllyylKDCG0tQCfQgeja28eV3jC/gsbFiXGZ806
q2gAn2/gNf5FA2gg/4RmZ9NRPsknNmN3
=U1LF
-----END PGP SIGNATURE-----

------enig2EHHHDGUVAVNHRTRWDHTB--
