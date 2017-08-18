From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 0/6] Add RSS to DPAA 1.x Ethernet driver
Date: Fri, 18 Aug 2017 11:56:22 +0300
Message-ID: <1503046588-24349-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set introduces Receive Side Scaling for the DPAA Ethernet
driver. Documentation is updated with details related to the new
feature and limitations that apply.
Added also a small fix.

Iordache Florinel-R70177 (1):
  fsl/fman: enable FMan Keygen

Madalin Bucur (5):
  dpaa_eth: use multiple Rx frame queues
  dpaa_eth: enable Rx hashing control
  dpaa_eth: add NETIF_F_RXHASH
  Documentation: networking: add RSS information
  dpaa_eth: check allocation result

 Documentation/networking/dpaa.txt                  |  68 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  72 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |   2 +
 .../net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c   |   3 +
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c | 118 ++++
 drivers/net/ethernet/freescale/fman/Makefile       |   2 +-
 drivers/net/ethernet/freescale/fman/fman.c         |  26 +
 drivers/net/ethernet/freescale/fman/fman.h         |   2 +
 drivers/net/ethernet/freescale/fman/fman_keygen.c  | 783 +++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fman_keygen.h  |  46 ++
 drivers/net/ethernet/freescale/fman/fman_port.c    |  51 +-
 drivers/net/ethernet/freescale/fman/fman_port.h    |   7 +
 12 files changed, 1167 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_keygen.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_keygen.h

-- 
2.1.0
