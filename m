From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28 2/4] myri10ge: Rename DCA-related firmware counters
Date: Fri, 12 Sep 2008 19:48:06 +0200
Message-ID: <48CAAB56.8020103@myri.com>
References: <48CAAAEF.1060205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1963 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753407AbYILRtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 13:49:40 -0400
In-Reply-To: <48CAAAEF.1060205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the cryptic "dca_capable" to "dca_capable_firmware"
and "dca_enabled" to "dca_device_present" in the firmware
counters.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2008-09-12 19:27:21.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-09-12 19:27:23.000000000 +0200
@@ -1688,7 +1688,7 @@
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
 #ifdef CONFIG_DCA
-	"dca_capable", "dca_enabled",
+	"dca_capable_firmware", "dca_device_present",
 #endif
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered",


