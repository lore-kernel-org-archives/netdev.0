From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/7] myri10ge: indentation cleanups
Date: Mon, 11 Dec 2006 11:24:37 +0100
Message-ID: <457D31E5.5090600@myri.com>
References: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42164 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762751AbWLKKY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:24:57 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <457D31B2.30505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Indentation cleanups to synchronize to our tree which is automatically
indent'ed.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:50:26.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:08.000000000 +0100
@@ -273,9 +273,9 @@
 
 #define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
 
-static inline void put_be32(__be32 val, __be32 __iomem *p)
+static inline void put_be32(__be32 val, __be32 __iomem * p)
 {
-	__raw_writel((__force __u32)val, (__force void __iomem *)p);
+	__raw_writel((__force __u32) val, (__force void __iomem *)p);
 }
 
 static int
@@ -2206,7 +2206,7 @@
 	struct myri10ge_cmd cmd;
 	struct myri10ge_priv *mgp;
 	struct dev_mc_list *mc_list;
-	__be32 data[2] = {0, 0};
+	__be32 data[2] = { 0, 0 };
 	int err;
 
 	mgp = netdev_priv(dev);
@@ -2625,7 +2625,7 @@
 static void myri10ge_watchdog(struct work_struct *work)
 {
 	struct myri10ge_priv *mgp =
-		container_of(work, struct myri10ge_priv, watchdog_work);
+	    container_of(work, struct myri10ge_priv, watchdog_work);
 	u32 reboot;
 	int status;
 	u16 cmd, vendor;


