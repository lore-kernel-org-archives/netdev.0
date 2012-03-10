From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc 2012-03-09
Date: Sat, 10 Mar 2012 00:46:49 +0000
Message-ID: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-B2HqrFOQhcn8x6NRim87"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32135 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756028Ab2CJAq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:46:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-B2HqrFOQhcn8x6NRim87
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit ffcb97388b1d41b1db063eb041cb9af408662127=
:

  Merge branch 'master' of git://gitorious.org/linux-can/linux-can-next (20=
12-03-04 21:59:39 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 460eeaa03c5c0af32a388337a6e1f0f1acd043ce)

1. Fix a bug in SR-IOV support that I introduced while cleaning it up
prior to upstreaming.
2. Show the part number for all boards at probe time, not just the ones
we have specific code for.
3. Improve self-test reliability, and test interrupts & events
immediately after bringing an interface up.
4. Improve adaptive IRQ moderation.
5. Various cleanup.

Ben.

Ben Hutchings (9):
      sfc: Remove redundant function efx_nic_has_mc()
      sfc: Update comments on efx_rx_packet_gro()
      sfc: Remove TX completions from adaptive IRQ scoring
      sfc: Raise self-test timeouts
      sfc: Test all event queues in parallel
      sfc: Encapsulate access to efx_{channel,nic}::last_irq_cpu in self-te=
st
      sfc: Run event/IRQ self-test asynchronously when interface is brought=
 up
      sfc: Remove efx_channel::last_eventq_read_ptr
      sfc: Log the part number on probe

Robert Stonehouse (1):
      sfc: Fix calculation of vf_i in map_vi_index()

 drivers/net/ethernet/sfc/efx.c           |   63 +++++++++-
 drivers/net/ethernet/sfc/efx.h           |    2 +-
 drivers/net/ethernet/sfc/falcon_boards.c |   13 --
 drivers/net/ethernet/sfc/net_driver.h    |    8 +-
 drivers/net/ethernet/sfc/nic.c           |   11 +-
 drivers/net/ethernet/sfc/nic.h           |   21 ++--
 drivers/net/ethernet/sfc/rx.c            |    7 +-
 drivers/net/ethernet/sfc/selftest.c      |  192 ++++++++++++++++++++------=
---
 drivers/net/ethernet/sfc/selftest.h      |    3 +
 drivers/net/ethernet/sfc/siena.c         |    3 +-
 drivers/net/ethernet/sfc/siena_sriov.c   |    2 +-
 11 files changed, 222 insertions(+), 103 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-B2HqrFOQhcn8x6NRim87
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJPWqR5AAoJEGkILBsOca60hpYH/38FQNepIQ0k0gIB9aVWr0i9
3y/h6rJnzHQ7YSHR4V/HJ/1c56gn3JWRJwdkc/x3YIiYAR5T/O1D42btS1ClF/GN
2AKnRBkuz+q/tJTmbtmnLdRO6OYs+SibcZpg8D+OrtlWXCKcLOYxmcepw90W8rI0
v6YvmbfhCjsuXX1wZ8NQCCRzWF/TWBCxud5LrEu4jv1JJjZV0bvkqdTKTxaWke6N
hUO3eLLdsD5kEMCn6xoL+CTSzX65cD3LKBuvVtMfVbyZFjf0ZVVKkcoF2motK4oz
EgHxxWfRHKiccrnTMkb4CSOGmwvW3AkEqZgyOO4X458B0ccVHjHwSl3BJzoJVFI=
=FkI2
-----END PGP SIGNATURE-----

--=-B2HqrFOQhcn8x6NRim87--
