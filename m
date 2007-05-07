From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/6] myri10ge: update firmware headers
Date: Mon, 07 May 2007 23:49:59 +0200
Message-ID: <463F9F07.70500@myri.com>
References: <463F9E9E.8000808@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1864 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966705AbXEGVt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:49:59 -0400
In-Reply-To: <463F9E9E.8000808@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update myri10ge firmware headers to those of 1.4.16.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge_mcp.h |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: linux-git/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge_mcp.h	2007-05-07 23:20:45.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge_mcp.h	2007-05-07 23:21:11.000000000 +0200
@@ -200,6 +200,13 @@
 	/* data0, data1 = bus addr,
 	 * data2 = sizeof(struct mcp_irq_data) from driver point of view, allows
 	 * adding new stuff to mcp_irq_data without changing the ABI */
+
+	MXGEFW_CMD_UNALIGNED_TEST,
+	/* same than DMA_TEST (same args) but abort with UNALIGNED on unaligned
+	 * chipset */
+
+	MXGEFW_CMD_UNALIGNED_STATUS
+	    /* return data = boolean, true if the chipset is known to be unaligned */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -212,7 +219,8 @@
 	MXGEFW_CMD_ERROR_HASH_ERROR,
 	MXGEFW_CMD_ERROR_BAD_PORT,
 	MXGEFW_CMD_ERROR_RESOURCES,
-	MXGEFW_CMD_ERROR_MULTICAST
+	MXGEFW_CMD_ERROR_MULTICAST,
+	MXGEFW_CMD_ERROR_UNALIGNED
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40
@@ -228,6 +236,10 @@
 	/* 40 Bytes */
 	__be32 send_done_count;
 
+#define MXGEFW_LINK_DOWN 0
+#define MXGEFW_LINK_UP 1
+#define MXGEFW_LINK_MYRINET 2
+#define MXGEFW_LINK_UNKNOWN 3
 	__be32 link_up;
 	__be32 dropped_link_overflow;
 	__be32 dropped_link_error_or_filtered;


