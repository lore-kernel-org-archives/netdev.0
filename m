From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v5 0/2] net: ethernet: mediatek: add enhancements to RX path
Date: Sat, 3 Sep 2016 17:59:25 +0800
Message-ID: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:54559 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753202AbcICJ7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 05:59:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Changes since v1:
- fix message typos and add coverletter
  
Changes since v2:
- split from the previous series for submitting add enhancements as 
a series targeting 'net-next' and add indents before comments.

Changes since v3:
- merge the patch using PDMA RX path
- fixed the input of mtk_poll_rx is with the remaining budget

Changes since v4:
- save one wmb and register update when no packet is being handled
inside mtk_poll_rx call
- fixed incorrect return packet count from mtk_napi_rx

Sean Wang (2):
  net: ethernet: mediatek: enhance RX path by reducing the frequency of
    the memory barrier used
  net: ethernet: mediatek: enhance RX path by aggregating more SKBs into
    NAPI

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

-- 
1.9.1
