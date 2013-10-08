From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-10-08
Date: Tue, 8 Oct 2013 18:41:31 +0100
Message-ID: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-tpo2SOP3IJ2MyLiOH9OG"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56378 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab3JHRlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:41:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-tpo2SOP3IJ2MyLiOH9OG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 5e8a402f831dbe7ee831340a91439e46f0d38acd=
:

  tcp: do not forget FIN in tcp_shifted_skb() (2013-10-04 14:16:36 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.12

for you to fetch changes up to ecb1c9cc215cb5a4390b714d8b09de637f54fa3f:

  sfc: Only bind to EF10 functions with the LinkCtrl and Trusted flags (201=
3-10-07 20:11:19 +0100)

Some more fixes for EF10 support; hopefully the last lot:

1. Fixes for reading statistics, from Edward Cree and Jon Cooper.
2. Addition of ethtool statistics for packets dropped by the hardware
before they were associated with a specific function, from Edward Cree.
3. Only bind to functions that are in control of their associated port,
as the driver currently assumes this is the case.

Ben.

----------------------------------------------------------------
Ben Hutchings (1):
      sfc: Only bind to EF10 functions with the LinkCtrl and Trusted flags

Edward Cree (3):
      sfc: Fix internal indices of ethtool stats for EF10
      sfc: Refactor EF10 stat mask code to allow for more conditional stats
      sfc: Add PM and RXDP drop counters to ethtool stats

Jon Cooper (1):
      sfc: Add rmb() between reading stats and generation count to ensure c=
onsistency

Matthew Slattery (1):
      sfc: Add definitions for new stats counters and capability flag

 drivers/net/ethernet/sfc/ef10.c      | 87 +++++++++++++++++++++++++++-----=
----
 drivers/net/ethernet/sfc/mcdi.c      | 18 +++++++-
 drivers/net/ethernet/sfc/mcdi_pcol.h | 56 ++++++++++++++++++++++-
 drivers/net/ethernet/sfc/nic.c       |  9 ++--
 drivers/net/ethernet/sfc/nic.h       | 12 +++++
 5 files changed, 151 insertions(+), 31 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-tpo2SOP3IJ2MyLiOH9OG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEcBAABCAAGBQJSVEPLAAoJEGkILBsOca60JWsH/3JdWRemGd0ESsbgEeAZD+S+
+nT41jDULEUBus/41c5KE4mY/l9rGNfpXQxj6ODMyFbhPYk0calgY8KdBbRL6/ki
9dNQqIDOGUp2gLwFybWQZYsbk55ZmCuUg8ZD4Jr030KeKn8QvfreF+6m7LS60nrF
idFeOpikoIxzHvPYEGcLxics3jiursKxO+UdkNdIBAuwLuL5re4AYAxFBKXSWFfu
UHUvDuTLgP8wneJbWOtyIENB0adw8ja3R7CUPi/jO9XU94vpRx9B7yO7+1KlcO8F
px76kHS/JWCwju4frgfbLAwP4PebZzYqM5ujpLaiP1kdpczWSHQ19sXcmLQjBVo=
=uEIc
-----END PGP SIGNATURE-----

--=-tpo2SOP3IJ2MyLiOH9OG--
