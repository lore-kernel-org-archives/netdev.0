From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH] net: compile renesas directory if NET_VENDOR_RENESAS is configured
Date: Tue, 25 Aug 2015 16:57:56 +0900
Message-ID: <1440489476-26700-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57231 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbbHYH6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 03:58:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

Currently the renesas ethernet driver directory is compiled if SH_ETH is
configured rather than NET_VENDOR_RENESAS. Although incorrect that was
quite harmless as until recently as SH_ETH configured the only driver in
the renesas directory. However, as of c156633f1353 ("Renesas Ethernet AVB
driver proper") the renesas directory includes another driver, configured
by RAVB, and it makes little sense for it to have a hidden dependency on
SH_ETH.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
[horms: rewrote changelog]
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index f42177b11723..ddfc808110a1 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -65,7 +65,7 @@ obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_QUALCOMM) += qualcomm/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
-obj-$(CONFIG_SH_ETH) += renesas/
+obj-$(CONFIG_NET_VENDOR_RENESAS) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
 obj-$(CONFIG_NET_VENDOR_ROCKER) += rocker/
 obj-$(CONFIG_NET_VENDOR_SAMSUNG) += samsung/
-- 
2.1.4
