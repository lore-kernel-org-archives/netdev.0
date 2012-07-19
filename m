From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH net-next] asix: AX88172A driver depends on phylib
Date: Thu, 19 Jul 2012 14:02:19 +0200
Message-ID: <1342699339-13871-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	<kernel-janitors@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:51398 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab2GSMA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 08:00:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 16626b0cc3d5afe250850f96759b241f8a403b52 the asix
driver depends on the phylib. Select phylib when the asix driver is
selected.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: kernel-janitors@vger.kernel.org
Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 833e32f..c1ae769 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -134,6 +134,7 @@ config USB_NET_AX8817X
 	tristate "ASIX AX88xxx Based USB 2.0 Ethernet Adapters"
 	depends on USB_USBNET
 	select CRC32
+	select PHYLIB
 	default y
 	help
 	  This option adds support for ASIX AX88xxx based USB 2.0
-- 
1.7.0.4
