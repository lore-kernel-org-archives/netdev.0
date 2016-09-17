From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next v3 0/3] net: ethernet: mediatek: add HW LRO functions
Date: Sat, 17 Sep 2016 23:54:07 +0800
Message-ID: <1474127650-20271-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:57883 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752257AbcIQPy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 11:54:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series add the large receive offload (LRO) functions by hardware and
the ethtool functions to configure RX flows of HW LRO.

changes since v3:
- Respin the patch by the newer driver
- Move the dts description of hwlro to optional properties

changes since v2:
- Add ndo_fix_features to prevent NETIF_F_LRO off while RX flow is programmed
- Rephrase the dts property is a capability if the hardware supports LRO

changes since v1:
- Add HW LRO support
- Add ethtool hooks to set LRO RX flows

Nelson Chang (3):
  net: ethernet: mediatek: add HW LRO functions of PDMA RX rings
  net: ethernet: mediatek: add ethtool functions to configure RX flows
    of HW LRO
  net: ethernet: mediatek: add dts configuration to enable HW LRO

 .../devicetree/bindings/net/mediatek-net.txt       |   2 +
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 433 +++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  75 +++-
 3 files changed, 485 insertions(+), 25 deletions(-)

-- 
1.9.1
