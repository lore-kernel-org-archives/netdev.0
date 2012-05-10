From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-05-09
Date: Thu, 10 May 2012 03:26:39 +0100
Message-ID: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-KdH8yG+y/sE2Ss0+I3/d"
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51823 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751668Ab2EJC0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:26:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-KdH8yG+y/sE2Ss0+I3/d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 2e7d21c54adbab6d10481eddc685328f89bb6389=
:

  e1000e: Fix merge conflict (net->net-next) (2012-05-09 12:06:39 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit ba62b2a8608ca52234fc8bea27bfebbdc4f98c2e)

1. A fix for recovery from some hardware failure modes, by Stuart Hodgson.
2. Reduction of RX jitter, by David Riddoch.
3. ethtool interface and implementation for reading plug-in modules, mostly=
 by
   Stuart Hodgson.
4. A minor fix to PCI device cleanup.

Ben.

Ben Hutchings (3):
      sfc: Fix missing cleanup in failure path of efx_pci_probe()
      ethtool: Split ethtool_get_eeprom() to allow for additional EEPROM ac=
cessors
      sfc: Implement module EEPROM access for SFE4002 and SFN4112F

David Riddoch (2):
      sfc: Fill RX rings completely full, rather than to 95% full
      sfc: By default refill RX rings as soon as space for a batch

Stuart Hodgson (3):
      sfc: Do not attempt to flush queues if DMA is disabled
      ethtool: Extend the ethtool API to obtain plugin module eeprom data
      sfc: Added support for new ethtool APIs for obtaining module eeprom

 drivers/net/ethernet/sfc/efx.c        |   36 +++++++++------
 drivers/net/ethernet/sfc/ethtool.c    |   35 +++++++++++++++
 drivers/net/ethernet/sfc/mcdi_phy.c   |   76 +++++++++++++++++++++++++++++=
++++
 drivers/net/ethernet/sfc/net_driver.h |    8 ++-
 drivers/net/ethernet/sfc/qt202x_phy.c |   33 ++++++++++++++
 drivers/net/ethernet/sfc/rx.c         |   31 ++++++-------
 include/linux/ethtool.h               |   33 ++++++++++++++
 net/core/ethtool.c                    |   71 +++++++++++++++++++++++++++--=
-
 8 files changed, 282 insertions(+), 41 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-KdH8yG+y/sE2Ss0+I3/d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJPqydgAAoJEGkILBsOca60b4IIALGakR/LqDu8R/n+BtBBbQ3o
YX3wG85SIIt1GgKcMHB9f0PByhyrdseZN0eCKxUlnxV5HLhUQS4vNLH9T2PeKYSe
fzQrgQkfNaYDwxxHUIceKjpKEOTvSymnZ9ZXX4KIajCr25ChbobpE5xC0grhglb0
zSjqhoPuOjrl1Z4NfpBRqMbCVqfCJtzbupgwYW2WfX0M29R6n30jFg9+4ZrYI+sb
xiPTvMDd0aknMBp5ZilAl9hBVBuArg+TbNhIX8ylKYoz1PY4iO85NoqaZS/K/PDY
3ygs4u0e2sQ6g2Zw6uNRNRVDRAzHKjGBmOeuOFkk0Jhq/DQIvg55UeePPjzJ5OI=
=5fZO
-----END PGP SIGNATURE-----

--=-KdH8yG+y/sE2Ss0+I3/d--
