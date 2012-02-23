From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-02-23
Date: Thu, 23 Feb 2012 17:38:54 +0000
Message-ID: <1330018734.2511.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-8NcNnCC2gSYtYY0QNsaW"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7208 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752207Ab2BWRjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:39:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-8NcNnCC2gSYtYY0QNsaW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 0b0a635f79f91f3755b6518627ea06dd0dbfd523=
:

  bnx2x: update driver version to 1.72.10-0 (2012-02-20 19:34:08 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 73e0026fb2bee4f2ca85c702040e143ec504eaa6)

Just some small fixes this time.

Ben.

Ben Hutchings (5):
      sfc: Specify that the VFDI status page has page alignment and size
      sfc: Correct validation of peer_page_count in efx_vfdi_set_status_pag=
e()
      sfc: Reverse initial buffer table allocation to allow for later resiz=
ing
      sfc: Minor formatting cleanup
      sfc: Correct efx_for_each_possible_channel_tx_queue() to skip non-TX =
channels

 drivers/net/ethernet/sfc/bitfield.h    |    4 ++--
 drivers/net/ethernet/sfc/efx.c         |    7 ++++++-
 drivers/net/ethernet/sfc/mcdi_mon.c    |    2 +-
 drivers/net/ethernet/sfc/net_driver.h  |    9 ++++++---
 drivers/net/ethernet/sfc/siena_sriov.c |   11 ++++++-----
 drivers/net/ethernet/sfc/tx.c          |    2 +-
 drivers/net/ethernet/sfc/vfdi.h        |    3 ++-
 7 files changed, 24 insertions(+), 14 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-8NcNnCC2gSYtYY0QNsaW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJPRnmuAAoJEGkILBsOca60+IoIAMaz9GVS23qdjyljc4Cpdyyz
O7QINjqLqyH7PzZ4BEShBvJo8zEhal55YHyDfuyFpfhAc6t4zzoBSRUH+WeYwQyb
LHw4pkCYIM9H7Wqbt45SA/VxpLKfoL7KvgP1Lo/R8t7tTfRaFJPqffn+a/fmt9+N
/RAe2TqV5AkqmTfnO1288a+W2g4pZfQEiL6jOqenXSP7HriGl71LSRXx2hS9mN2i
Rmd7j2l7G0/+Yscy7tcuKMzdUHz1jKHOcVYZ4tIpNe3Pjv0cE9pSjtlS1vpT1Bnx
QqrLC4cNjWSBC9m3totK/hUcgI+eaPU+0kZb+VsR0xpcLka5+VmlysWDSGqiKtM=
=Z1CE
-----END PGP SIGNATURE-----

--=-8NcNnCC2gSYtYY0QNsaW--
