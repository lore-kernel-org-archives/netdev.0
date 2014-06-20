From: varkabhadram@gmail.com
Subject: [PATCH net-next v7 2/3] ieee802154: cc2520: add driver to kernel build system
Date: Fri, 20 Jun 2014 17:47:16 +0530
Message-ID: <53a4275f.6ac3440a.5afd.56c6@mx.google.com>
References: <y>
 <1403266637-6150-1-git-send-email-y>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	sowjanyap@cdac.in, venkatas@cdac.in, santoshk@cdac.in,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:64464 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966074AbaFTMVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:21:52 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so3060055pac.33
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 05:21:52 -0700 (PDT)
In-Reply-To: <1403266637-6150-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>


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
