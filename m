From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next 0/3] net: ethernet: mediatek: add HW LRO functions
Date: Tue, 13 Sep 2016 21:54:23 +0800
Message-ID: <1473774866-3156-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:39024 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751234AbcIMNyi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 09:54:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patches add the large receive offload (LRO) functions by hardware and
the ethtool functions to configure RX flows of HW LRO.

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
