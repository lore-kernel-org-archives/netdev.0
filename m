From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next 0/3] net: ethernet: mediatek: check the hw lro capability by the chip id instead of the dtsi
Date: Mon, 3 Oct 2016 15:18:48 +0800
Message-ID: <1475479131-19822-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:42727 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752223AbcJCHTD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 03:19:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series modify to check if hw lro is supported by the chip id.

Because hw lro started to be supported from MT7623, the proper way to check if
the feature is capable is to judge by the chip id instead of by the dtsi.

Nelson Chang (3):
  net: ethernet: mediatek: get the chip id by ETHDMASYS registers
  net: ethernet: mediatek: get hw lro capability by the chip id instead
    of by the dtsi
  net: ethernet: mediatek: remove hwlro property in the device tree

 .../devicetree/bindings/net/mediatek-net.txt       |  2 --
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 39 ++++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  6 ++++
 3 files changed, 43 insertions(+), 4 deletions(-)

-- 
1.9.1
