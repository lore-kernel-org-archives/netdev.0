From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: update firmware headers to 1.4.41
Date: Tue, 24 Mar 2009 11:01:34 +0100
Message-ID: <49C8AF7E.9000903@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1787 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759321AbZCXKg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 06:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge firmware headers to firmware version 1.4.41.

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2009-01-22 08:05:56.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2009-03-24 10:50:10.000000000 +0100
@@ -9,6 +9,7 @@
 #define MCP_TYPE_ETH 0x45544820	/* "ETH " */
 #define MCP_TYPE_MCP0 0x4d435030	/* "MCP0" */
 #define MCP_TYPE_DFLT 0x20202020	/* "    " */
+#define MCP_TYPE_ETHZ 0x4554485a	/* "ETHZ" */
 
 struct mcp_gen_header {
 	/* the first 4 fields are filled at compile time */
@@ -43,7 +44,15 @@
 	unsigned msix_table_addr;	/* start address of msix table in firmware */
 	unsigned bss_addr;	/* start of bss */
 	unsigned features;
+	unsigned ee_hdr_addr;
 	/* 8 */
 };
 
+struct zmcp_info {
+	unsigned info_len;
+	unsigned zmcp_addr;
+	unsigned zmcp_len;
+	unsigned mcp_edata;
+};
+
 #endif				/* __MYRI10GE_MCP_GEN_HEADER_H__ */


