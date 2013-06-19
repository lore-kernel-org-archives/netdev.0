From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-06-19
Date: Wed, 19 Jun 2013 23:16:09 +0100
Message-ID: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-USpHgO6rj8bsKZIgeP0E"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23191 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935070Ab3FSWQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:16:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-USpHgO6rj8bsKZIgeP0E
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit df09b36f2225b84571b3d5eda2e2683412320713=
:

  macvtap: enable multiqueue flag (2013-06-07 23:49:09 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git master

for you to fetch changes up to 7585a2d50af2450f9acecb90a0c289d46310317a:

  sfc: Improve test for IOMMU in use (2013-06-19 21:44:19 +0100)

----------------------------------------------------------------
Alexandre Rames (1):
      sfc: Fix EEH with legacy interrupts.

Andy Lutomirski (1):
      sfc: Enable accelerated RFS on vlans

Ben Hutchings (6):
      sfc: Report software timestamping capabilities
      sfc: Define and set RX buffer flag for packets parsed as TCP
      sfc: Do not pass non-TCP packets into GRO code
      sfc: Prefetch RX skb header area
      sfc: Fix IRQ cleanup in case of a probe failure
      sfc: Improve test for IOMMU in use

Jon Cooper (3):
      sfc: Enable RX checksum offload for packets not handled by GRO
      sfc: Increase size of RX SKB header area
      sfc: Implement RX SKB cache to improve latency

 drivers/net/ethernet/sfc/efx.c        | 40 +++----------------
 drivers/net/ethernet/sfc/efx.h        |  1 +
 drivers/net/ethernet/sfc/ethtool.c    | 16 +++++++-
 drivers/net/ethernet/sfc/filter.c     | 15 ++++++-
 drivers/net/ethernet/sfc/net_driver.h |  6 +++
 drivers/net/ethernet/sfc/nic.c        | 74 ++++++++++++++++++++++++++++++-=
----
 drivers/net/ethernet/sfc/nic.h        |  4 +-
 drivers/net/ethernet/sfc/ptp.c        | 13 +++---
 drivers/net/ethernet/sfc/rx.c         | 63 +++++++++++++++++++++++++----
 9 files changed, 169 insertions(+), 63 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-USpHgO6rj8bsKZIgeP0E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQEcBAABCAAGBQJRwi2pAAoJEGkILBsOca60JO0IAJFxKAoJPI/B6N/WdPWSUMlz
B1vk6H5V4xdkYbyQRPj4pHwxwTK7v/h2+xr2X3hSS7nBLultYExVAoSEeN59buAG
7yAttzdE1PO+B5I5KwFd5sIKZL6epoTnT2l1yiCShq0V49J6N7iOgILbVVjm3p8q
JvJCddNC+wn1N1PGP030h+uCC00aTaLx32/BmnfPA4epfPUK9HXfBwRaQwRKF0M6
P4oIjF7LNSKCtiql2aANeB89zrSL3Bm6rR6GDKIKYcQQ52gKd3+uPlYWC/7ALCVU
44Zn4VeNvKUnWtjpJU8+/TqOPwhubCVcKCT1iE7AuZQp2zXjCFGWJ7e+HI1CT/k=
=Ok//
-----END PGP SIGNATURE-----

--=-USpHgO6rj8bsKZIgeP0E--
