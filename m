From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 0/4] net-next: mediatek: add support for ethernet on MT7622 SoC
Date: Mon, 17 Jul 2017 18:06:21 +0800
Message-ID: <cover.1500285278.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

Changes since v1:
- add refinement for ethernet clock management
- take out the code block for ESW, add it until ESW driver is actually introduced

The series adds the driver for ethernet controller found on MT7622 SoC.
There are additions against with previous MT7623 SoC such as shared SGMII
given for the dual GMACs and built-in 5-ports 10/100 embedded switch support
(ESW). Thus more clocks consumers and SGMII hardware setup for the extra
features are all introduced here and as for the support for ESW that would be
planned to add in the separate patch integrating with DSA infrastructure
in the future.

Currently testing successfully is done with those patches for the conditions
such as GMAC2 with IP1001 PHY via RGMII and GMAC1/2 with RTL8211F PHY via SGMII.

Sean Wang (4):
  dt-bindings: net: mediatek: add support for MediaTek MT7623 and MT7622
    SoC
  net-next: mediatek: add platform data to adapt into various hardware
  net-next: mediatek: add support for MediaTek MT7622 SoC
  MAINTAINERS: add Sean/Nelson as MediaTek ethernet maintainers

 .../devicetree/bindings/net/mediatek-net.txt       |  12 +-
 MAINTAINERS                                        |   2 +
 drivers/net/ethernet/mediatek/Kconfig              |   6 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 142 +++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  73 ++++++++++-
 5 files changed, 214 insertions(+), 21 deletions(-)

-- 
2.7.4
