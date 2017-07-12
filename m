From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 0/4] net-next: mediatek: add support for ethernet on MT7622 SoC
Date: Wed, 12 Jul 2017 11:37:41 +0800
Message-ID: <cover.1499829241.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:18286 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752543AbdGLDhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 23:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

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
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 143 +++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  73 ++++++++++-
 5 files changed, 216 insertions(+), 20 deletions(-)

-- 
2.7.4
