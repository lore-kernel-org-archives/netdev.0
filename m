From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-03-03
Date: Fri, 3 Mar 2017 15:04:06 +0100
Message-ID: <e7d1906d-fec4-217d-f444-2f5996d45f8b@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="XwspQDhiCtotJeH3bDgW6SVew23uTBAxg"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59709 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751323AbdCCOEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 09:04:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XwspQDhiCtotJeH3bDgW6SVew23uTBAxg
Content-Type: multipart/mixed; boundary="1j3R9tMtSrQhsk5tQTud4RJ816VjtQUOu";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <e7d1906d-fec4-217d-f444-2f5996d45f8b@pengutronix.de>
Subject: pull-request: can-next 2017-03-03

--1j3R9tMtSrQhsk5tQTud4RJ816VjtQUOu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 3 patches for net-next/master.

The patches are by Yegor Yefremov and convert the ti_hecc driver into a
DT only driver, as there is no in-tree user of the old platform driver
interface anymore.

regards,
Marc

---

The following changes since commit 2d6be4abf514fc26c83d239c7f31da1f95e4a3=
1d:

  Merge tag 'for-linus-4.11' of git://git.code.sf.net/p/openipmi/linux-ip=
mi (2017-02-28 21:06:30 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.12-20170303

for you to fetch changes up to b08bb1376263026cb947923ed6c559addb908be6:

  can: ti_hecc: Convert TI HECC driver to DT only driver (2017-03-03 15:0=
1:16 +0100)

----------------------------------------------------------------
linux-can-next-for-4.12-20170303

----------------------------------------------------------------
Yegor Yefremov (3):
      ARM: dts: AM35x: Add hecc node
      can: ti_hecc: Add TI HECC DT binding documentation
      can: ti_hecc: Convert TI HECC driver to DT only driver

 .../devicetree/bindings/net/can/ti_hecc.txt        |  32 ++++
 arch/arm/boot/dts/am3517.dtsi                      |  12 ++
 drivers/net/can/ti_hecc.c                          | 170 +++++++++++----=
------
 include/linux/can/platform/ti_hecc.h               |  44 ------
 4 files changed, 132 insertions(+), 126 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/ti_hecc.txt=

 delete mode 100644 include/linux/can/platform/ti_hecc.h

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--1j3R9tMtSrQhsk5tQTud4RJ816VjtQUOu--

--XwspQDhiCtotJeH3bDgW6SVew23uTBAxg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAli5d9kACgkQHv7KIOw4
HPZmJAgAgY1Oh+Ex3a8aTLTX3JrRkDbgI7o/Sel5jFGAQRnsp5gYsVZEYJpzyfya
EE5EwPjkpp1qx+ZSilcg3RcaHDrJTV6qK7DKtj4EOjaRoZ/gI8JsrDTj0Y8L6kN8
7Pg4D1Xmb++Sh7tMEQpQgz5wMmODH/1oHNY3McNBndmpE40aut8UwyMPssPZqDBa
iQJUQVDFMFhuBmAlj1+pmFMUuS9lg0YHk5Lhb37irPcR8xogiQ4JupeQMpX3aCgH
xUWL0qIlhDfUft4H9taNIJe0o78/PsKKvkr+0qU4aUTgqqVnLGo27PKha95ruGoX
c/k5bW0ke+f4TzRpi24s+veAzgu0vw==
=DAet
-----END PGP SIGNATURE-----

--XwspQDhiCtotJeH3bDgW6SVew23uTBAxg--
