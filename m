From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v6 2/3] ieee802154: cc2520: add driver to kernel build system
Date: Fri, 20 Jun 2014 11:18:13 +0530
Message-ID: <1403243294-15400-3-git-send-email-varkab@cdac.in>
References: <1403243294-15400-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	devicetree@vger.kernel.org, sowjanyap@cdac.in, venkatas@cdac.in,
	santoshk@cdac.in, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:62972 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933914AbaFTFtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 01:49:45 -0400
In-Reply-To: <1403243294-15400-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ieee802154/Kconfig  |   11 +++++++++++
 drivers/net/ieee802154/Makefile |    1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 3e89bea..8b7ae51 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -51,3 +51,14 @@ config IEEE802154_MRF24J40
 
 	  This driver can also be built as a module. To do so, say M here.
 	  the module will be called 'mrf24j40'.
+
+config IEEE802154_CC2520
+	depends on IEEE802154_DRIVERS && MAC802154
+	tristate "CC2520 transceiver driver"
+	depends on SPI
+	---help---
+	  Say Y here to enable the CC2520 SPI 802.15.4 wireless
+	  controller.
+
+	  This driver can also be built as a module. To do so, say M here.
+	  the module will be called 'cc2520'.
diff --git a/drivers/net/ieee802154/Makefile b/drivers/net/ieee802154/Makefile
index abb0c08..655cb95 100644
--- a/drivers/net/ieee802154/Makefile
+++ b/drivers/net/ieee802154/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
 obj-$(CONFIG_IEEE802154_FAKELB) += fakelb.o
 obj-$(CONFIG_IEEE802154_AT86RF230) += at86rf230.o
 obj-$(CONFIG_IEEE802154_MRF24J40) += mrf24j40.o
+obj-$(CONFIG_IEEE802154_CC2520) += cc2520.o
-- 
1.7.9.5
