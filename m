From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [pull request - net-next] my WAN and ixp4xx ethernet stuff
Date: Mon, 22 Dec 2008 02:43:23 +0100
Message-ID: <m3skohq91g.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55010 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbYLVBnZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 20:43:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

The following changes since commit 221b3d60cbb2740ec7d46a4f1ea6d3318a11=
2e51:
  Anton Vorontsov (1): ucc_geth: Remove UGETH_FILTERING dead code
(IOW, your current net-next)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for=
-david

Please pull. Thanks.

Julia Lawall (1):
      drivers/net/wan: Remove redundant test

Krzysztof Ha=B3asa (12):
      IXP4xx: check for queue being empty in qmgr_release_queue().
      IXP4xx: clear IRQ stat in qmgr_disable_irq().
      IXP4xx: Silence section mismatch warning in Ethernet driver.
      IXP4xx: Make the Ethernet driver use built-in netdev stats.
      IXP4xx: Add PHYLIB support to Ethernet driver.
      IXP4xx: Add PHYLIB MII ioctl to the Ethernet driver.
      IXP4xx: Add ethtool support to Ethernet driver.
      WAN: Add IXP4xx HSS HDLC driver.
      Update MAINTAINERS entries for IXP4xx and WAN network drivers.
      IXP4xx: move common debugging from network drivers to QMGR module=
=2E
      HDLC_PPP: Fix Configure-Ack to return original options as
            required by the standard.
      Convert ixp4xx_eth driver to use net_device_ops.

 MAINTAINERS                              |    7 +-
 arch/arm/mach-ixp4xx/include/mach/qmgr.h |   35 +-
 arch/arm/mach-ixp4xx/ixp4xx_qmgr.c       |   44 +-
 drivers/net/arm/Kconfig                  |    2 +-
 drivers/net/arm/ixp4xx_eth.c             |  337 ++++----
 drivers/net/wan/Kconfig                  |    7 +
 drivers/net/wan/Makefile                 |    1 +
 drivers/net/wan/hdlc_ppp.c               |   11 +-
 drivers/net/wan/ixp4xx_hss.c             | 1325 ++++++++++++++++++++++=
++++++++
 drivers/net/wan/pc300_drv.c              |    5 +-
 10 files changed, 1587 insertions(+), 187 deletions(-)
 create mode 100644 drivers/net/wan/ixp4xx_hss.c

--=20
Krzysztof Halasa
