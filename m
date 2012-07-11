From: Dave Jones <davej@redhat.com>
Subject: Add missing license tag to nci.
Date: Wed, 11 Jul 2012 14:31:57 -0400
Message-ID: <20120711183157.GA19417@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilane@ti.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754663Ab2GKScE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 14:32:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nci: module license 'unspecified' taints kernel.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index d560e6f..f18f207 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -27,6 +27,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": %s: " fmt, __func__
 
+#include <linux/module.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
 #include <linux/completion.h>
@@ -878,3 +879,5 @@ static void nci_cmd_work(struct work_struct *work)
 			  jiffies + msecs_to_jiffies(NCI_CMD_TIMEOUT));
 	}
 }
+
+MODULE_LICENSE("GPL");
