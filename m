From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-02-12
Date: Fri, 07 Mar 2014 10:45:51 +0100
Message-ID: <5319954F.3080208@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="IQpMglkDPSwSIKppr0p2vmnmEjFUeHI6T"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37064 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbaCGJqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 04:46:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IQpMglkDPSwSIKppr0p2vmnmEjFUeHI6T
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of twelve patches for net-next/master.

Alexander Shiyan contributes two patches for the mcp251x, one making
the driver more quiet and the other one improves the compile time
coverage by removing the #ifdef CONFIG_PM_SLEEP. Then two patches for
the flexcan driver by me, one removing the #ifdef CONFIG_PM_SLEEP, too,
the other one making use of platform_get_device_id(). Another patch by
me which converts the janz-ican3 driver to use netdev_<level>(). The
remaining 7 patches are by Oliver Hartkopp, they add CAN FD support to
the netlink configuration interface.

regards,
Marc

---

The following changes since commit f3253339a47ff3690ce52e2acd95ec295f8521=
b3:

  bonding: options handling cleanup (2014-03-06 16:08:52 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.15-20140307

for you to fetch changes up to dd22586dec4c1444608affd83b1fedd520280ab4:

  can: add bittiming check at interface open for CAN FD (2014-03-07 09:18=
:23 +0100)

----------------------------------------------------------------
linux-can-next-for-3.15-20140307

----------------------------------------------------------------
Alexander Shiyan (2):
      can: mcp251x: Make driver more quiet
      can: mcp251x: Remove #ifdef CONFIG_PM_SLEEP

Marc Kleine-Budde (3):
      can: flexcan: Remove #ifdef CONFIG_PM_SLEEP
      can: flexcan: make use of platform_get_device_id()
      can: janz-ican3: convert dev_<level> printing to netdev_<level>

Oliver Hartkopp (7):
      can: preserve skbuff protocol in can_put_echo_skb
      can: only send bitrate data via netlink when available
      can: move sanity check for bitrate and tq into can_get_bittiming
      can: provide a separate bittiming_const parameter to bittiming func=
tions
      can: introduce the data bitrate configuration for CAN FD
      can: allow to change the device mtu for CAN FD capable devices
      can: add bittiming check at interface open for CAN FD

 drivers/net/can/dev.c            | 159 ++++++++++++++++++++++++++++++---=
------
 drivers/net/can/flexcan.c        |  10 +--
 drivers/net/can/janz-ican3.c     |  64 ++++++++--------
 drivers/net/can/mcp251x.c        |  17 ++---
 include/linux/can/dev.h          |   7 +-
 include/uapi/linux/can/netlink.h |   3 +
 6 files changed, 172 insertions(+), 88 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |






--IQpMglkDPSwSIKppr0p2vmnmEjFUeHI6T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMZlU8ACgkQjTAFq1RaXHMl4gCfScY812/lPQRLSuneZbI0KPz1
rjgAoJKtasU/uUm8Xh37OK+aBg2JrDop
=JKYJ
-----END PGP SIGNATURE-----

--IQpMglkDPSwSIKppr0p2vmnmEjFUeHI6T--
