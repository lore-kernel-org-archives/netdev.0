From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-05-18
Date: Thu, 18 May 2017 10:56:31 +0200
Message-ID: <28d10e0b-bc7a-de01-8fd7-9eb3c1f70f3c@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="mkq4mIvFgsRwE8WH0vKxtqSad8or68oP1"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mkq4mIvFgsRwE8WH0vKxtqSad8or68oP1
Content-Type: multipart/mixed; boundary="CTgi3gkxnALGqvtgs9CgpDaPaOiSDBwe5";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <28d10e0b-bc7a-de01-8fd7-9eb3c1f70f3c@pengutronix.de>
Subject: pull-request: can-next 2017-05-18

--CTgi3gkxnALGqvtgs9CgpDaPaOiSDBwe5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

All 4 patches are by Quentin Schulz, they add deep deep Suspend/Resume
support to the m_can driver.

regards,
Marc

---

The following changes since commit 1fc4d180b3c6bed0e7f5160bcd553aec895949=
62:

  Merge branch 'phy-marvell-cleanups' (2017-05-17 16:27:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.13-20170518

for you to fetch changes up to d14ccea0e71a55ad02bf4e1cb378bbece282d5cf:

  can: m_can: add deep Suspend/Resume support (2017-05-18 10:32:48 +0200)=


----------------------------------------------------------------
linux-can-next-for-4.13-20170518

----------------------------------------------------------------
Quentin Schulz (4):
      can: m_can: move Message RAM initialization to function
      can: m_can: make m_can_start and m_can_stop symmetric
      can: m_can: factorize clock gating and ungating
      can: m_can: add deep Suspend/Resume support

 drivers/net/can/m_can/m_can.c | 87 ++++++++++++++++++++++++++-----------=
------
 1 file changed, 53 insertions(+), 34 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--CTgi3gkxnALGqvtgs9CgpDaPaOiSDBwe5--

--mkq4mIvFgsRwE8WH0vKxtqSad8or68oP1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkdYcAACgkQHv7KIOw4
HPZr9Af/UWVZBNv5wza3EvOUAetNdg0DMiaGasLn7pd3GKzm3cbEmsneJrwnFBff
TH3h3c0/XgbwGzWLUH8BjKo7Z323/f1Ly+OR1Cfdw7XzOBfYEmoLQjMncDstsmuB
3VrEzMVeKbw3Yt7dkluu+yHAiie4HNLZt6TeE9SZNx7/tnJzCRe+YZTWGxKrMkG+
f7AvPO9FczAwmz2pVX7yjyyhuknS5E2NEbFONpcfwJ0njBu+JgqAQN3qZ6BT2AF8
Z+KdJsnRczekEgpeOXoxisK/O5RCRFg6Td1VY1WEZdumIjAvQxHLPRkacApcdv9y
JdCLP2AkfRLC1BQGmFQnj0ckW5fvcA==
=3UNB
-----END PGP SIGNATURE-----

--mkq4mIvFgsRwE8WH0vKxtqSad8or68oP1--
