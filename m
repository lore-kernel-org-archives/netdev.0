From: Henne <henne@nachtwindheim.de>
Subject: [PATCH] [NET] [VELOCITY] remove an unused function from the header
Date: Tue, 15 Aug 2006 11:41:11 +0200
Message-ID: <44E196B7.6060305@nachtwindheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server6.greatnet.de ([83.133.96.26]:436 "EHLO
	server6.greatnet.de") by vger.kernel.org with ESMTP id S965237AbWHOJl5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 05:41:57 -0400
To: akpm@osdl.org, jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henrik Kretzschmar <henne@nachtwindheim.de>

Removes an unused function from the via-velocity-driver.
It doesn't make the binary smaller, but the source cleaner.

Signed-off-by: Henrik Kretzschmar <henne@nachtwindheim.de>

---

--- linux-2.6.18-rc2-git6/drivers/net/via-velocity.h	2006-07-30 23:25:59.000000000 +0200
+++ linux/drivers/net/via-velocity.h	2006-08-07 15:24:54.000000000 +0200
@@ -262,25 +262,6 @@
 	dma_addr_t skb_dma;
 };
 
-/**
- *	alloc_rd_info		-	allocate an rd info block
- *
- *	Alocate and initialize a receive info structure used for keeping
- *	track of kernel side information related to each receive
- *	descriptor we are using
- */
-
-static inline struct velocity_rd_info *alloc_rd_info(void)
-{
-	struct velocity_rd_info *ptr;
-	if ((ptr = kmalloc(sizeof(struct velocity_rd_info), GFP_ATOMIC)) == NULL)
-		return NULL;
-	else {
-		memset(ptr, 0, sizeof(struct velocity_rd_info));
-		return ptr;
-	}
-}
-
 /*
  *	Used to track transmit side buffers.
  */


