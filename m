From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 0/3]  add support for RGMII on GMAC0 through TRGMII hardware module
Date: Tue, 20 Sep 2016 15:59:17 +0800
Message-ID: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:20735 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932281AbcITH7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 03:59:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

By default, GMAC0 is connected to built-in switch called
MT7530 through the proprietary interface called Turbo RGMII
(TRGMII). TRGMII also supports well for RGMII as generic external
PHY uses but requires some slight changes to the setup of TRGMII 
and doesn't have well support on current driver.

So this patchset
1) provides the slight changes of the setup for RGMII can work
   through TRGMII
2) adds additional setting "trgmii" about phy-mode on device tree
   to make GMAC0 distinguish which mode it runs
3) changes dynamically source clock, TX/RX delay and interface
   mode on TRGMII for adapting various link

Sean Wang (3):
  net: ethernet: mediatek: add extension of phy-mode for TRGMII
  net: ethernet: mediatek: add support for GMAC0 connecting with
    external PHY through TRGMII
  net: ethernet: mediatek: add the dts property to set if TRGMII
    supported on GMAC0

 .../devicetree/bindings/net/mediatek-net.txt       |  5 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 57 ++++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        | 32 ++++++++++++
 3 files changed, 90 insertions(+), 4 deletions(-)

-- 
1.9.1
