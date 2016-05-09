From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-05-09
Date: Mon, 9 May 2016 12:17:03 +0200
Message-ID: <5730639F.2030104@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="01IK2NHu8lTafGMBamH7KRchb1v6ksUWe"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--01IK2NHu8lTafGMBamH7KRchb1v6ksUWe
Content-Type: multipart/mixed; boundary="pXitTt0Wqltxw3OWRWoRvd7cV7TIsKStO"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <5730639F.2030104@pengutronix.de>
Subject: pull-request: can-next 2016-05-09

--pXitTt0Wqltxw3OWRWoRvd7cV7TIsKStO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 12 patches for net-next/master.

Alexander Gerasiov and Nikita Edward Baruzdin each contribute a patch
improving the sja1000 driver. Amitoj Kaur Chawla's patch converts the
mcp251x driver to alloc_workqueue(). A patch by Oliver Hartkopp fixes
the handling of CAN config options. Andreas Gr=C3=B6ger improves the erro=
r
handling in the janz-ican3 driver. The patch by Maximilian Schneider
for the gs_usb improves probing of the USB driver. Finally there are 6
improvement patches by Marek Vasut for the ifi CAN driver.

regards,
Marc

---
The following changes since commit 908578e7d5f69087241434c872f8f4a8ab7004=
5f:

  Merge branch 'sh_eth-sw-reset' (2016-05-09 00:15:31 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.7-20160509

for you to fetch changes up to 5bbd655a8bd000579d135ddf30660f759db89996:

  can: ifi: Add more detailed error reporting (2016-05-09 11:07:28 +0200)=


----------------------------------------------------------------
linux-can-next-for-4.7-20160509

----------------------------------------------------------------
Alexander Gerasiov (1):
      can: sja1000: Fix error location forwarding

Amitoj Kaur Chawla (1):
      can: mcp251x: Replace create_freezable_workqueue with alloc_workque=
ue

Andreas Gr=C3=B6ger (1):
      can: janz-ican3: error handling for CAL/CANopen firmware

Marek Vasut (6):
      can: ifi: Start NAPI poll on bus warning too
      can: ifi: Update timing configuration code
      can: ifi: Unify timing constants
      can: ifi: Treat CAN_CTRLMODE_FD_NON_ISO correctly
      can: ifi: Increment TX counters only on real transmission
      can: ifi: Add more detailed error reporting

Maximilian Schneider (1):
      can: gs_usb: modify the usb device table to use only the first usb =
interface

Nikita Edward Baruzdin (1):
      can: sja1000: plx_pci: Add support for Marathon CAN-bus-PCIe card

Oliver Hartkopp (1):
      can: fix handling of unmodifiable configuration options

 drivers/net/can/dev.c                 |  56 +++++++++-
 drivers/net/can/ifi_canfd/ifi_canfd.c | 187 ++++++++++++++++++++++++----=
------
 drivers/net/can/janz-ican3.c          | 104 +++++++++++++++++--
 drivers/net/can/m_can/m_can.c         |   2 +-
 drivers/net/can/sja1000/plx_pci.c     |  64 ++++++++++--
 drivers/net/can/sja1000/sja1000.c     |   6 +-
 drivers/net/can/spi/mcp251x.c         |   3 +-
 drivers/net/can/usb/gs_usb.c          |   3 +-
 include/linux/can/dev.h               |  22 +++-
 9 files changed, 367 insertions(+), 80 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--pXitTt0Wqltxw3OWRWoRvd7cV7TIsKStO--

--01IK2NHu8lTafGMBamH7KRchb1v6ksUWe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXMGOfAAoJED07qiWsqSVqr7QIAKRe4AYZHMi+31SBmRXeQiN6
40fr+tX5dBJP8YbxUKrVgmXkWT42DStEy8nbMXsFtxJPyC3OD/u9KB430ha3FFrj
ietiCfI/1wpJeLweLeGeWpJOjeXIJMjfCL9WnkcsGXYLBlCi4nuusyY4HCcIx/SF
AZZbjNj5E/tIlL3bBxI6ZubIXbG73+g8FfwMnxaklZZkJaR9TqrWeN3NDI7jx5Jp
thLFihviTRmlAjt6+wBmyTQXPGAiKtgx392stKq0oiE+DbqT2Toygfo2QNDMFDhL
U1/ebZXGxSigWNoygD6mTCLdrdDBnqhYnzEy47QfT8m2bDo3OWJ5PU4TC6qifFI=
=JjZN
-----END PGP SIGNATURE-----

--01IK2NHu8lTafGMBamH7KRchb1v6ksUWe--
