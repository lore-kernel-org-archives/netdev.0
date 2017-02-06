From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-02-06
Date: Mon, 6 Feb 2017 15:50:48 +0100
Message-ID: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lJfKLqWCVj1nF50HOweinSArbglUgUCTL"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lJfKLqWCVj1nF50HOweinSArbglUgUCTL
Content-Type: multipart/mixed; boundary="HomdeE6x2UJdW7gr6geI1PftTK3bfwtER";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
Subject: pull-request: can-next 2017-02-06

--HomdeE6x2UJdW7gr6geI1PftTK3bfwtER
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 16 patches for net-next/master.

The first two patches by David Jander and me add the rx-offload
framework for CAN devices to the kernel. The remaining 14 patches
convert the flexcan driver to make use of it.

regards,
Marc

---

The following changes since commit bd092ad1463ca0990581fa992e12a9b0ed295d=
25:

  Merge branch 'remove-__napi_complete_done' (2017-02-05 16:11:59 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.11-20170206

for you to fetch changes up to 096de07f1d7156e500dec5abe89e9b44314e38e5:

  can: flexcan: switch imx6 and vf610 to timestamp based offloading (2017=
-02-06 15:13:45 +0100)

----------------------------------------------------------------
linux-can-next-for-4.11-20170206

----------------------------------------------------------------
David Jander (1):
      can: rx-offload: Add support for HW fifo based irq offloading

Marc Kleine-Budde (15):
      can: rx-offload: Add support for timestamp based irq offloading
      can: flexcan: add missing register definitions
      can: flexcan: remove write-only member pdata of struct flexcan_priv=

      can: flexcan: make declaration of devtype_data const
      can: flexcan: do_bus_err(): convert rx_,tx_errors into bool
      can: flexcan: flexcan_poll_state(): no need to initialize new_state=
, rx_state, tx_state
      can: flexcan: flexcan_poll_bus_err(): fold in do_bus_err()
      can: flexcan: flexcan_irq(): don't unconditionally return IRQ_HANDL=
ED
      can: flexcan: calculate default value for imask1 during runtime
      can: flexcan: make TX mailbox selectable during runtime
      can: flexcan: make use of rx-offload's irq_offload_fifo
      can: flexcan: activate individual RX masking and initialize reg_rxi=
mr
      can: flexcan: add quirk FLEXCAN_QUIRK_ENABLE_EACEN_RRS
      can: flexcan: add support for timestamp based rx-offload
      can: flexcan: switch imx6 and vf610 to timestamp based offloading

 drivers/net/can/Makefile       |   3 +-
 drivers/net/can/flexcan.c      | 419 ++++++++++++++++++++++++-----------=
------
 drivers/net/can/rx-offload.c   | 289 ++++++++++++++++++++++++++++
 include/linux/can/rx-offload.h |  59 ++++++
 4 files changed, 593 insertions(+), 177 deletions(-)
 create mode 100644 drivers/net/can/rx-offload.c
 create mode 100644 include/linux/can/rx-offload.h

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--HomdeE6x2UJdW7gr6geI1PftTK3bfwtER--

--lJfKLqWCVj1nF50HOweinSArbglUgUCTL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAliYjUgACgkQHv7KIOw4
HPZRcgf/c6qHRMKZRCT2yjympsQULUcYIiZbSjbI2yC5xnGfCfSW2WRin1zHOV7W
qGLAs8sYYyHgi3bh4qFxvpGm/4p+XAAp3nZSwC6RBhEKFv7twIkSQT7IUReu+zkB
KEDEqSYP7rvqnZj6/ZtN/zoyA2T+2WnsqqnMSwUEQm++6YVB8WAmqybfNTTD+3fe
upS9e1RP9eRD0rrhTd8DE8A3hrRrwiBSHJrhV8sp8c25YyiLRm5b8yzD7dGDm0oA
s3wi4g9zyUgQhAZfuvNa0VzayY0q9tzdsQeEg5a0kHis8Wxq9LIK4y7hNIVhoB4G
wLy3vf/A9O2tzcBYRorMeW93zkLCNg==
=vLBy
-----END PGP SIGNATURE-----

--lJfKLqWCVj1nF50HOweinSArbglUgUCTL--
