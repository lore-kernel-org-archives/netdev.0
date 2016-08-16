From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 0/2] Add enhancements to RX path
Date: Tue, 16 Aug 2016 14:17:12 +0800
Message-ID: <1471328235-16724-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:49198 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753131AbcHPGRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 02:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fix gives some enhancements about RX path handling.
and thanks for Sergei Shtylyov helps reviewing during v2 to v3.

v1 -> v2: Fix message typos and add coverletter
  
v2 -> v3: 
Split from the previous series for submitting add enhancements 
as a series targeting 'net-next' and add indents before comments. 

Sean Wang (2):
  net: ethernet: mediatek: enhance RX path by reducing the frequency of
    the memory barrier used
  net: ethernet: mediatek: enhance RX path by aggregating more SKBs
    into NAPI

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

-- 
1.7.9.5
