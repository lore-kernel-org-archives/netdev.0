From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-07-18
Date: Wed, 18 Jul 2012 19:16:32 +0100
Message-ID: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-ggLmUPxrQSi9FXvhJTG6"
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Andrew Jackson <ajackson@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51687 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753213Ab2GRSQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-ggLmUPxrQSi9FXvhJTG6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit f150bd7f8cf742c4cdd0c929aa494ef72f7f5b13=
:

  driver: net: ethernet: cpsw: runtime PM support (2012-07-18 09:40:54 -070=
0)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 2482aab313c3657557f1dad4c1b20c0934b84919)

This adds PTP hardware timestamping support for SFC9000-family
controllers with the appropriate peripheral (currently SFN5322F and
SFN6322F boards).

Ben.

Ben Hutchings (3):
      sfc: Support variable-length response to MCDI GET_BOARD_CFG
      sfc: Expose FPGA bitfile partition through MTD
      sfc: Bump version to 3.2

Stuart Hodgson (4):
      sfc: Add explicit RX queue flag to channel
      sfc: Add channel specific receive_skb handler and post_remove callbac=
k
      sfc: Allow efx_mcdi_rpc to be called in two parts
      sfc: Add support for IEEE-1588 PTP

 drivers/net/ethernet/sfc/Kconfig      |    7 +
 drivers/net/ethernet/sfc/Makefile     |    1 +
 drivers/net/ethernet/sfc/efx.c        |   17 +-
 drivers/net/ethernet/sfc/efx.h        |    1 +
 drivers/net/ethernet/sfc/ethtool.c    |    1 +
 drivers/net/ethernet/sfc/mcdi.c       |   44 +-
 drivers/net/ethernet/sfc/mcdi.h       |    6 +
 drivers/net/ethernet/sfc/mcdi_pcol.h  |    1 +
 drivers/net/ethernet/sfc/mtd.c        |    7 +-
 drivers/net/ethernet/sfc/net_driver.h |   29 +-
 drivers/net/ethernet/sfc/nic.h        |   31 +
 drivers/net/ethernet/sfc/ptp.c        | 1519 +++++++++++++++++++++++++++++=
++++
 drivers/net/ethernet/sfc/rx.c         |   20 +-
 drivers/net/ethernet/sfc/siena.c      |    1 +
 drivers/net/ethernet/sfc/tx.c         |    6 +
 15 files changed, 1673 insertions(+), 18 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/ptp.c

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.




--=-ggLmUPxrQSi9FXvhJTG6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJQBv2AAAoJEGkILBsOca60H7QH/2htv/DWtc3YM/uKJn+X/qth
BUkWpu3uE7MremrFU70H8VYLlghEH3/+28jBXjXbvXxXP4Wy121xR8WVXNMlFOfF
4REQbEw5FwNSVrj+jpiVVOHr1Bc7JriwT+Hn9+ncOVbyWb4SdqzBenZzts2EXof4
VkBaQqq3q5c8u/fwE1k5IJ1foDcCN1vno0NtXHH+PfAESPdq5rknFCIXwthBL/dq
FSxIdVhFM5JSlF7YAfsHIE1tIK0CH4c0D87Qvcs1z5yR+dg5veAT5bZMnNIt54ug
xlJCKQ7QKTraZf9828C/n5WObmI7YOnh2VmpjdH2DbDZ2yMLG99htIzzurvlTxc=
=l+ie
-----END PGP SIGNATURE-----

--=-ggLmUPxrQSi9FXvhJTG6--
