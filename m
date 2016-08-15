From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH v2 0/5] Fix warning, issue and give some enhancements
Date: Tue, 16 Aug 2016 01:51:21 +0800
Message-ID: <1471283487-24113-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:2779 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752920AbcHORvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 13:51:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the following warning and issues and gives some 
enhancements about RX path handling.

v1 -> v2: fix message typos and add coverletter

Sean Wang (5):
  net: ethernet: mediatek: add REVMII and fix RMII mode supported by
    GMAC
  net: ethernet: mediatek: fix flow control settings on GMAC0 is not
    being enabled properly
  net: ethernet: mediatek: fix runtime warning raised by inconsistent
    struct device pointers passed to DMA API
  net: ethernet: mediatek: enhance RX path by reducing the frequency of
    the memory barrier used
  net: ethernet: mediatek: enhance RX path by aggregating more skbs
    into NAPI

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   70 ++++++++++++++++-----------
 1 file changed, 42 insertions(+), 28 deletions(-)

-- 
1.7.9.5
