From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next v4 0/2] net: ethernet: mediatek: modify to use the PDMA for Ethernet RX
Date: Fri, 26 Aug 2016 01:09:41 +0800
Message-ID: <1472144983-5048-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:30947 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752794AbcHYRJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 13:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series have some modifications and refines to support Ethernet RX by the PDMA.

changes since v4:
- Remove the redundant OR operation in mtk_hw_init()

changes since v3:
- Add GDM hardware settings to send packets to PDMA for RX

changes since v2:
- Fix the bugs of PDMA cpu index and interrupt settings in mtk_poll_rx()

changes since v1:
- Modify to use the PDMA instead of the QDMA for Ethernet RX

Nelson Chang (2):
  net: ethernet: mediatek: modify to use the PDMA instead of the QDMA
    for Ethernet RX
  net: ethernet: mediatek: modify GDM to send packets to the PDMA for RX

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 79 ++++++++++++++++-------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 31 ++++++++++-
 2 files changed, 75 insertions(+), 35 deletions(-)

-- 
1.9.1
