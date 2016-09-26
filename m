From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next 0/2] net: ethernet: mediatek: some bug fixes for PDAM and HW LRO
Date: Mon, 26 Sep 2016 14:33:48 +0800
Message-ID: <1474871630-4134-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:62519 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1761469AbcIZGd7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 02:33:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Add to stop PDMA while stopping the frame engine
2) Modify the register settings for LRO relinquishments
3) Jump out from the waiting loop while LRO relinquishments are done

Nelson Chang (2):
  net: ethernet: mediatek: add to stop PDMA while stopping the frame
    engine
  net: ethernet: mediatek: bug fix to disable HW LRO

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 ++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)
 mode change 100644 => 100755 drivers/net/ethernet/mediatek/mtk_eth_soc.c
 mode change 100644 => 100755 drivers/net/ethernet/mediatek/mtk_eth_soc.h

-- 
1.9.1
