From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 01/15]bnx2x: Rename bnx2x.c to bnx2x_main.c
Date: Tue, 17 Jun 2008 17:46:53 +0300
Message-ID: <1213714013.5817.171.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1209 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756785AbYFQOrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is the rename of bnx2x.c to bnx2x_main.c. It is too big to be
sent as a regular patch but it boils down to a simple patch to the 
Makefile (below) and this git command:
git mv drivers/net/bnx2x.c drivers/net/bnx2x_main.c

The Makefile:
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c96fe20..f4dbb0e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -67,6 +67,7 @@ obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
 obj-$(CONFIG_BNX2X) += bnx2x.o
+bnx2x-objs := bnx2x_main.o
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>




