From: brice@myri.com
Subject: [patch 1/4] myri10ge - Drop unused pm_state
Date: Mon, 03 Jul 2006 18:02:31 -0400
Message-ID: <20060703220516.933682000@loulous.org>
References: <20060703220230.606593000@myri.com>
Cc: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:44471 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932148AbWGCWIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:08:13 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=myri10ge1-drop_pm_state.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pm_state field in the myri10ge_priv structure is unused. Drop it.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:00:22.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:00:27.000000000 -0400
@@ -188,7 +188,6 @@
 	int vendor_specific_offset;
 	u32 devctl;
 	u16 msi_flags;
-	u32 pm_state[16];
 	u32 read_dma;
 	u32 write_dma;
 	u32 read_write_dma;

