From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-05-26
Date: Mon, 26 May 2014 09:41:59 +0200
Message-ID: <5382F047.2030600@pengutronix.de>
References: <537EF718.2020203@pengutronix.de>	<20140523.154433.1565372421278669500.davem@davemloft.net> <20140523.162554.1697403825084761042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="a7u8SHu8E3Cu9FVdAmJxNEUoid27EH5Cl"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40817 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaEZHmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 03:42:09 -0400
In-Reply-To: <20140523.162554.1697403825084761042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--a7u8SHu8E3Cu9FVdAmJxNEUoid27EH5Cl
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/23/2014 10:25 PM, David Miller wrote:
>>> this is a pull request of two patches for net-next/master. Kedareswar=
a
>>> rao Appana contributes support for the xilinx CAN core found on the
>>> zynq and microblaze SOCs.

> Somethings not right, it looks like a forgotten git add on your side.

Doh, yes, the file is in my tree, but not in the patch. Now the fixed
version:

This is a pull request of two patches for net-next/master. Kedareswara
rao Appana contributes support for the xilinx CAN core found on the
zynq and microblaze SoCs.

Marc
---

The following changes since commit 3bea8eddfebe1c61ea824dd2880d4368791edc=
1f:

  Merge branch 'net-sysfs-docs' (2014-05-26 01:02:39 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.16-20140526

for you to fetch changes up to b1201e44f50b017a4972a337058b36b40c90abca:

  can: xilinx CAN controller support (2014-05-26 09:36:31 +0200)

----------------------------------------------------------------
linux-can-next-for-3.16-20140526

----------------------------------------------------------------
Kedareswara rao Appana (2):
      can: Add xilinx CAN device tree bindings documentation
      can: xilinx CAN controller support

 .../devicetree/bindings/net/can/xilinx_can.txt     |   44 +
 drivers/net/can/Kconfig                            |    8 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/xilinx_can.c                       | 1208 ++++++++++++++=
++++++
 4 files changed, 1261 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/xilinx_can.=
txt
 create mode 100644 drivers/net/can/xilinx_can.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--a7u8SHu8E3Cu9FVdAmJxNEUoid27EH5Cl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOC8EcACgkQjTAFq1RaXHOtOQCfbokQ6casDnJnQ9ycjY9kFyZs
+F4AmgL+5RUp8s+Bj2VsdSx9LXmamR3K
=4btF
-----END PGP SIGNATURE-----

--a7u8SHu8E3Cu9FVdAmJxNEUoid27EH5Cl--
