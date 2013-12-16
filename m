From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-12-16
Date: Mon, 16 Dec 2013 21:29:10 +0000
Message-ID: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-VBf8SQYEN7XKTizFV+wQ"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8544 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab3LPV3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:29:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-VBf8SQYEN7XKTizFV+wQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit bbbe7149bf0bd14432373de39315505e7a133acc=
:

  sfc: Remove unnecessary condition for processing the TX timestamp queue (=
2013-12-12 22:07:18 +0000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to a0bc3487e431eaea381c2c882a41274e9a02f028:

  sfc: Fix RX drop filters for EF10 (2013-12-16 19:01:27 +0000)

Miscellaneous changes for 3.14:

1. Add more information to some WARN messages.
2. Refactor pushing of RSS configuration, from Andrew Rybchenko.
3. Refactor handling of automatic (device address list) vs manual (RX
NFC) MAC filters.
4. Implement clearing of manual RX filters on EF10 when ntuple offload
is disabled.
5. Remove definitions that are unused since the RX buffer allocation
changes, from Andrew Rybchenko.
6. Improve naming of some statistics, from Shradha Shah.
7. Add statistics for PTP support code.
8. Fix insertion of RX drop filters on EF10.

Ben.

----------------------------------------------------------------
Andrew Rybchenko (3):
      sfc: Change efx_nic_type::rx_push_indir_table to push hash key as wel=
l
      sfc: remove unused 'refcnt' from efx_rx_page_state
      sfc: remove unused 'enum efx_rx_alloc_method'

Ben Hutchings (7):
      sfc: Add more information to many warnings using WARN() and netdev_WA=
RN()
      sfc: Change priority and flags for automatic MAC filters
      sfc: Don't refer to 'stack' in filter implementation
      sfc: Allow filter removal only with exactly matching priority
      sfc: Implement efx_nic_type::filter_clear_rx operation for EF10
      sfc: Add PTP counters to ethtool stats
      sfc: Fix RX drop filters for EF10

Shradha Shah (1):
      sfc: Changed the statistic name emerg_{fetch,wait} to hlb_{fetch,wait=
}

 drivers/net/ethernet/sfc/ef10.c       | 251 ++++++++++++++++++++----------=
----
 drivers/net/ethernet/sfc/efx.c        |   2 +-
 drivers/net/ethernet/sfc/efx.h        |  11 --
 drivers/net/ethernet/sfc/ethtool.c    |  10 +-
 drivers/net/ethernet/sfc/falcon.c     |  26 +++-
 drivers/net/ethernet/sfc/farch.c      |  46 +++----
 drivers/net/ethernet/sfc/filter.h     |  17 ++-
 drivers/net/ethernet/sfc/net_driver.h |  20 +--
 drivers/net/ethernet/sfc/nic.h        |  14 +-
 drivers/net/ethernet/sfc/ptp.c        | 126 +++++++++++++++--
 drivers/net/ethernet/sfc/siena.c      |  45 +++---
 11 files changed, 362 insertions(+), 206 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-VBf8SQYEN7XKTizFV+wQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEcBAABCAAGBQJSr3CnAAoJEGkILBsOca60O54H/2uT9jdvjx45C1li4Sd4Tk12
xZbJTITJAU2w2xvcLwnCx+4smaSzg3ttd+TWNNKsLzf3J7/RJK+eAnWU39JgzXFB
JsE8CeSRuwN5eit1pS5k3Wuu61yc6mRIFQh902vlsUDMTQw2AwbnYqFQUu0S3J5a
tr8XFIYqCQalkGjmSWG51OuzK0fPTCfyIfhPRfkDBXscZqrd1Ymn4ZdyG60ZLH7J
b/2peBbX28Ec6PF7lIRleG8Y9EgXmB/zKfftxmLnwmMlB8eZYPbmPXttNADcZaPH
nKM1u0qW1PqJoJZeTMdPvNFAsvLhFuu5tYQG00w+fn1oX4DCO59TrbYIq3GHXPs=
=o2rZ
-----END PGP SIGNATURE-----

--=-VBf8SQYEN7XKTizFV+wQ--
