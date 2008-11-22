From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: update firmware headers
Date: Sat, 22 Nov 2008 10:23:10 +0100
Message-ID: <4927CF7E.60207@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1801 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752664AbYKVJXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:23:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge firmware headers.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-tmp/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-11-22 10:06:58.000000000 +0100
+++ net-next-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-10-29 10:25:24.000000000 +0100
@@ -41,6 +41,7 @@
 	unsigned short handoff_id_major;	/* must be equal */
 	unsigned short handoff_id_caps;	/* bitfield: new mcp must have superset */
 	unsigned msix_table_addr;	/* start address of msix table in firmware */
+	unsigned bss_addr;	/* start of bss */
 	/* 8 */
 };
 


