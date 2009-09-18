From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 05/12] gigaset: announce if built with debugging
Date: Sat, 19 Sep 2009 01:57:43 +0200 (CEST)
Message-ID: <20090919-patch-gigaset-05.tilman@imap.cc>
References: <20090919-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756928AbZISABE@vger.kernel.org>
In-Reply-To: <20090919-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mention in the driver load announcement whether the driver was built
with debugging messages enabled, to facilitate support.

Impact: informational message
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index e4141bf..edbcaa3 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -22,6 +22,12 @@
 #define DRIVER_AUTHOR "Hansjoerg Lipp <hjlipp@web.de>, Tilman Schmidt <tilman@imap.cc>, Stefan Eilers"
 #define DRIVER_DESC "Driver for Gigaset 307x"
 
+#ifdef CONFIG_GIGASET_DEBUG
+#define DRIVER_DESC_DEBUG " (debug build)"
+#else
+#define DRIVER_DESC_DEBUG ""
+#endif
+
 /* Module parameters */
 int gigaset_debuglevel = DEBUG_DEFAULT;
 EXPORT_SYMBOL_GPL(gigaset_debuglevel);
@@ -1110,7 +1116,7 @@ static int __init gigaset_init_module(void)
 	if (gigaset_debuglevel == 1)
 		gigaset_debuglevel = DEBUG_DEFAULT;
 
-	pr_info(DRIVER_DESC "\n");
+	pr_info(DRIVER_DESC DRIVER_DESC_DEBUG "\n");
 	return 0;
 }
 
-- 
1.6.2.1.214.ge986c
