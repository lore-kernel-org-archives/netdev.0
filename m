From: y@pengutronix.de
Subject: [PATCH] fec: use linux/*.h instead of asm/*.h
Date: Tue, 27 Jan 2009 11:24:02 +0100
Message-ID: <10021.7214938768$1233052003@news.gmane.org>
References: <1233051848-5994-1-git-send-email-y>
 <1233051848-5994-2-git-send-email-y>
 <1233051848-5994-3-git-send-email-y>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42893 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbZA0KZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:25:08 -0500
In-Reply-To: <1233051848-5994-3-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index f913c97..a44b4ee 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -36,15 +36,13 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
+#include <linux/io.h>
+#include <linux/irq.h>
 
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/pgtable.h>
 #include <asm/cacheflush.h>
-
 #include <asm/coldfire.h>
 #include <asm/mcfsim.h>
+
 #include "fec.h"
 
 #if defined(CONFIG_FEC2)
-- 
1.5.6.5

