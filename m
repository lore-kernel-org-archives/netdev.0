From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-07-17
Date: Tue, 17 Jul 2012 18:05:40 +0100
Message-ID: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-M3MleVxCC2O0Zn22lah1"
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51108 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751664Ab2GQRFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 13:05:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-M3MleVxCC2O0Zn22lah1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 141e369de698f2e17bf716b83fcc647ddcb2220c=
:

  xfrm: Initialize the struct xfrm_dst behind the dst_enty field (2012-07-1=
4 00:29:12 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit c2dbab39db1c3c2ccbdbb2c6bac6f07cc7a7c1f6)

1. Fix potential badness when running a self-test with SR-IOV enabled.
2. Fix calculation of some interface statistics that could run backward.
3. Miscellaneous cleanup.

Ben.

Ben Hutchings (10):
      sfc: Work around bogus 'uninitialised variable' warning
      sfc: Use generic DMA API, not PCI-DMA API
      sfc: Remove dead write to tso_state::packet_space
      sfc: Stop changing header offsets on TX
      sfc: Use strlcpy() to copy ethtool stats names
      sfc: Use dev_kfree_skb() in efx_end_loopback()
      sfc: Explain why efx_mcdi_exit_assertion() ignores result of efx_mcdi=
_rpc()
      sfc: Disable VF queues during register self-test
      sfc: Fix interface statistics running backward
      sfc: Correct some comments on enum reset_type

 drivers/net/ethernet/sfc/efx.c         |   10 ++--
 drivers/net/ethernet/sfc/enum.h        |    8 ++--
 drivers/net/ethernet/sfc/ethtool.c     |    2 +-
 drivers/net/ethernet/sfc/falcon.c      |   35 +++++++++++--
 drivers/net/ethernet/sfc/falcon_xmac.c |   12 ++--
 drivers/net/ethernet/sfc/filter.c      |    2 +-
 drivers/net/ethernet/sfc/mcdi.c        |   11 +++-
 drivers/net/ethernet/sfc/net_driver.h  |    9 ++-
 drivers/net/ethernet/sfc/nic.c         |   11 ++---
 drivers/net/ethernet/sfc/nic.h         |   18 ++++++
 drivers/net/ethernet/sfc/rx.c          |   22 ++++----
 drivers/net/ethernet/sfc/selftest.c    |   64 ++++++----------------
 drivers/net/ethernet/sfc/siena.c       |   37 ++++++++++---
 drivers/net/ethernet/sfc/tx.c          |   93 ++++++++++++++--------------=
----
 14 files changed, 181 insertions(+), 153 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-M3MleVxCC2O0Zn22lah1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJQBZtkAAoJEGkILBsOca603BMIAJnhd3C93nwqgjGrRewGM5n2
sdiLqKgJd4v3WUuzsvXF5UQHxDSHOk8PMYwRZF4M9C09HDJU871/tYiWsGD5hKKo
6E3hIQD3GNDH1P7Ydyye7Ez9Go0Sz8lF/sSmFOZt0z8WHwEseixgP8jvDAkykN8P
rYup7AemGi2RrDPI4OOgXBghENs+QwkeAY24QHa3OS5eP0gTX8N81pumEGX4PLke
F3KuDFrVrYQMibFDqdijAzaFXKmC4+AmtjLVDNnQodnsnBvBddezuOHVp0PX/DsC
pd004gTGOL+LUIEAmb+CKPZJtXoCoxo0UEWjgdvyhBwjumR50YPLQfHZs/zZgxs=
=K7Qc
-----END PGP SIGNATURE-----

--=-M3MleVxCC2O0Zn22lah1--
