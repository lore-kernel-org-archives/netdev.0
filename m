From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 0/2] net: stmmac: Support DWMAC5 and TSN
Date: Wed, 25 Oct 2017 15:02:37 +0100
Message-ID: <cover.1508938927.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This adds support for a new IP version (5) of dwmac and for
TSN features as defined by IEEE802.1Qbv-2015 and IEEE802.1Qbu.

Please review.

Best regards,
Jose Miguel Abreu

Jose Abreu (2):
  net: stmmac: Add support for DWMAC5 with TSN features
  bindings: net: stmmac: Add documentation for TSN parameters

 Documentation/devicetree/bindings/net/stmmac.txt   | 20 +++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 37 +++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c   | 99 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h   | 57 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  4 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 57 ++++++++++++-
 include/linux/stmmac.h                             | 11 +++
 9 files changed, 288 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h

-- 
1.9.1
