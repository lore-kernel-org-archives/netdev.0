From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: use linux/*.h instead of asm/*.h
Date: Tue, 27 Jan 2009 11:39:58 +0100
Message-ID: <1233052804-31228-4-git-send-email-s.hauer@pengutronix.de>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-2-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-3-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	frederic rodo <fred.rodo@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47167 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbZA0Kms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:42:48 -0500
In-Reply-To: <1233052804-31228-3-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

