From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/10] drivers/net/amd8111e.c: Fix continuation line formats
Date: Sun, 31 Jan 2010 12:02:09 -0800
Message-ID: <5f913ef7c2af30646e9c56eb4cb33a1d67d3a721.1264967500.git.joe@perches.com>
References: <cover.1264967493.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1653 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040Ab0AaUCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jan 2010 15:02:23 -0500
In-Reply-To: <cover.1264967493.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

String constants that are continued on subsequent lines with \
are not good.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/amd8111e.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 766aabf..c315480 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1176,8 +1176,7 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 			/* Schedule a polling routine */
 			__napi_schedule(&lp->napi);
 		} else if (intren0 & RINTEN0) {
-			printk("************Driver bug! \
-				interrupt while in poll\n");
+			printk("************Driver bug! interrupt while in poll\n");
 			/* Fix by disable receive interrupts */
 			writel(RINTEN0, mmio + INTEN0);
 		}
-- 
1.6.6.rc0.57.gad7a

