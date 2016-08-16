From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH net v3 0/3] Fix warning and issue
Date: Tue, 16 Aug 2016 13:55:12 +0800
Message-ID: <1471326915-15162-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:19774 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750928AbcHPFzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 01:55:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the following warning and issues

v1 -> v2: Fix message typos and add coverletter

v2 -> v3: Split from the previous series for submitting bug fixes 
as a series targeting 'net'

Sean Wang (3):
  net: ethernet: mediatek: fix RMII mode and add REVMII supported by
    GMAC
  net: ethernet: mediatek: fix flow control settings on GMAC0 is not
    being enabled properly
  net: ethernet: mediatek: fix runtime warning raised by inconsistent
    struct device pointers passed to DMA API

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   46 +++++++++++++++++----------
 1 file changed, 30 insertions(+), 16 deletions(-)

-- 
1.7.9.5
