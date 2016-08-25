From: Sean@vger.kernel.org, Wang@vger.kernel.org
Subject: [PATCH net 00/10] net: ethernet: mediatek: a couple of fixes
Date: Thu, 25 Aug 2016 18:22:27 +0800
Message-ID: <1472120557-15216-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:45961 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757184AbcHYK2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:28:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

a couple of fixes come out from integrating with linux-4.8 rc1
they all are verified and workable on linux-4.8 rc1

Sean Wang (10):
  net: ethernet: mediatek: fix fails from TX housekeeping due to
    incorrect port setup
  net: ethernet: mediatek: fix incorrect return value of devm_clk_get
    with EPROBE_DEFER
  net: ethernet: mediatek: fix API usage with skb_free_frag
  net: ethernet: mediatek: remove redundant free_irq for
    devm_request_irq allocated irq
  net: ethernet: mediatek: fix logic unbalance between probe and remove
  net: ethernet: mediatek: fix the loss of pin-mux setting for GMAC2
  net: ethernet: mediatek: fix issue of driver removal with interface is
    up
  net: ethernet: mediatek: fix the missing of_node_put() after node is
    used done inside mtk_mdio_init
  net: ethernet: mediatek: use devm_mdiobus_alloc instead of
    mdiobus_alloc inside mtk_mdio_init
  net: ethernet: mediatek: fix error handling inside mtk_mdio_init

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 74 +++++++++++++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  3 ++
 2 files changed, 52 insertions(+), 25 deletions(-)

-- 
1.9.1
