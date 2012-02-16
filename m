From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-02-16
Date: Thu, 16 Feb 2012 00:42:18 +0000
Message-ID: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-njpszInjbas1ixzu2//g"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27445 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751494Ab2BPAmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:42:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-njpszInjbas1ixzu2//g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit eb40d89276705a35c9a2e05793ae63411ae357eb=
:

  mlx4: add unicast steering entries to resource_tracker (2012-02-14 14:11:=
59 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit cd2d5b529cdb9bd274f3e4bc68d37d4d63b7f383)

The main change here is the addition of SR-IOV support.

Ben.

Ben Hutchings (18):
      sfc: Skip RX end-of-batch work on channels without an RX queue
      sfc: Do not retry hardware probe if it schedules a reset
      sfc: Replace some literal constants with EFX_PAGE_SIZE/EFX_BUF_SIZE
      sfc: Warn if unable to create MTDs
      sfc: Add support for configuring RX unicast/multicast default filters
      sfc: Add support for TX MAC filters
      sfc: Correct MAC filter bitfield definitions
      sfc: Generalise driver event generation
      sfc: Generate RX fill events based on RX queues, not channels
      sfc: Leave interrupts and event queues enabled whenever we can
      sfc: Use proper function to test for RX channel in efx_poll()
      sfc: Generalise event generation to cover VF-owned event queues
      sfc: Make buffer table indices and counts consistently unsigned
      sfc: Make all CPU/IRQ/channel/queue counts unsigned
      sfc: Add support for 'extra' channel types
      sfc: Pass NIC structure into efx_wanted_parallelism()
      sfc: Allocate SRAM between buffer table and descriptor caches at init=
 time
      sfc: Add SR-IOV back-end support for SFC9000 family

Steve Hodgson (1):
      sfc: Disable flow control during flushes

 drivers/net/ethernet/sfc/Kconfig       |    8 +
 drivers/net/ethernet/sfc/Makefile      |    1 +
 drivers/net/ethernet/sfc/efx.c         |  685 ++++++++------
 drivers/net/ethernet/sfc/efx.h         |    1 +
 drivers/net/ethernet/sfc/ethtool.c     |   62 +-
 drivers/net/ethernet/sfc/falcon.c      |   12 +-
 drivers/net/ethernet/sfc/filter.c      |  255 +++++-
 drivers/net/ethernet/sfc/filter.h      |   20 +-
 drivers/net/ethernet/sfc/mcdi.c        |   34 +
 drivers/net/ethernet/sfc/mcdi.h        |    2 +
 drivers/net/ethernet/sfc/mcdi_mac.c    |    4 +-
 drivers/net/ethernet/sfc/mtd.c         |    2 +-
 drivers/net/ethernet/sfc/net_driver.h  |  123 ++-
 drivers/net/ethernet/sfc/nic.c         |  524 ++++++-----
 drivers/net/ethernet/sfc/nic.h         |  102 ++-
 drivers/net/ethernet/sfc/regs.h        |   20 +-
 drivers/net/ethernet/sfc/rx.c          |    7 +-
 drivers/net/ethernet/sfc/siena.c       |   14 +-
 drivers/net/ethernet/sfc/siena_sriov.c | 1642 ++++++++++++++++++++++++++++=
++++
 drivers/net/ethernet/sfc/tx.c          |    2 +-
 drivers/net/ethernet/sfc/vfdi.h        |  254 +++++
 21 files changed, 3170 insertions(+), 604 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/siena_sriov.c
 create mode 100644 drivers/net/ethernet/sfc/vfdi.h

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-njpszInjbas1ixzu2//g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJPPFDqAAoJEGkILBsOca60c4gH/2Af1EZUK9Nitss+jYc6Xgwy
7c0vGeTaqDDB4dLz7JVnCxU97mbhGSQS59Qu7HUJur+iNGJBlSXD1rjQWXR/MYfz
WzCj+AmL3YMkSZx2USmgZo1DzOTPpBXsSrD+0A4mFB0Zd4kQj40jjdPoXMR4MtHT
PlX04lCBOlzU+XiqfToR77GI6IUZFC2lpsGB8SU1QY1vC1IXw/kaDaMAfOccO7/3
Yh3J40JTAYtpmsPrcSKBQ+DKwk0W4EwooDRcOh8LFHZYZtPaX3zQNDONVxAZkthT
NT+inuIBNnnfnuYkOqv8wPtfLnEUbIdj2GUoK7Gabj2XXDxkjSldMXgYbmssmCk=
=vAG6
-----END PGP SIGNATURE-----

--=-njpszInjbas1ixzu2//g--
