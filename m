From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-01-24
Date: Fri, 27 Jan 2017 10:02:09 +0100
Message-ID: <37eedb82-54d7-c7a9-0cd6-ed26738efff7@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="dh1eeTtbluMUlt1NECpWQkkeCvjkBoAdc"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47495 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932191AbdA0JCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 04:02:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dh1eeTtbluMUlt1NECpWQkkeCvjkBoAdc
Content-Type: multipart/mixed; boundary="6uv2CPvITEPI0pnPvA3U6JvlBFqrxFlXn";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <37eedb82-54d7-c7a9-0cd6-ed26738efff7@pengutronix.de>
Subject: pull-request: can-next 2017-01-24

--6uv2CPvITEPI0pnPvA3U6JvlBFqrxFlXn
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

The first patch by Oliver Hartkopp adds a netlink API to configure the
interface termination of a CAN card. The next two patches are by me and
add a netlink API to query and configure CAN interfaces that only
support fixed bitrates. The last patch by Colin Ian King simplifies the
return path in the softing_cs driver's softingcs_probe() function.

regards,
Marc

---

The following changes since commit d140199af510ad4749dc5e38b7922135258ba5=
fd:

  bpf, lpm: fix kfree of im_node in trie_update_elem (2017-01-23 21:17:35=
 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.11-20170124

for you to fetch changes up to 1e9bbb9bc2aa549d31fa0a0496ec33df0b3ae7a8:

  can: softing_cs: ret is never non-zero, so remove non-zero check and -E=
NODEV return (2017-01-24 13:52:00 +0100)

----------------------------------------------------------------
linux-can-next-for-4.11-20170124

----------------------------------------------------------------
Colin Ian King (1):
      can: softing_cs: ret is never non-zero, so remove non-zero check an=
d -ENODEV return

Marc Kleine-Budde (2):
      can: dev: can_changelink: allow to set bitrate on devices not provi=
ding {data_,}bittiming_const
      can: dev: add CAN interface API for fixed bitrates

Oliver Hartkopp (1):
      can: dev: add CAN interface termination API

 drivers/net/can/dev.c                | 136 +++++++++++++++++++++++++++++=
+++---
 drivers/net/can/softing/softing_cs.c |   2 +-
 include/linux/can/dev.h              |   8 +++
 include/uapi/linux/can/netlink.h     |   7 ++
 4 files changed, 142 insertions(+), 11 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |



--6uv2CPvITEPI0pnPvA3U6JvlBFqrxFlXn--

--dh1eeTtbluMUlt1NECpWQkkeCvjkBoAdc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAliLDJkACgkQPTuqJayp
JWpy4AgAvlInyuYr/imDWpEFnXCB/uCOVTgvpY8EZkqoubVUl00jwhOB5CHa38n/
KMnZDYQtTB88E+Pu7vIb8DpjbSe2BTwQZgKHV/lHeB1Ho9ghCU/rNx6SmZlOlPdJ
riF1FSDMN3YadSSiaFcntOJc0tWNEmUWyN3Elqm5mtJiSDo7VVyqSyrXie+NSSuc
CK//rCscPJ+vgDizaEMK5GJiUtY3TjwuFE30PhtobC7rK08uhO3rMpcxhTVQG9tb
aEUeDKTxzxop2nBDk6yEyw21LTlPoXCEFR3ibqjBpeE90NBWTnMvEPa12UGtXfhM
0kigbwCVpi+vGQuGY0+ndh2VnJipNA==
=W0by
-----END PGP SIGNATURE-----

--dh1eeTtbluMUlt1NECpWQkkeCvjkBoAdc--
