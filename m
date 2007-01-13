From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/8] e1000: clean up debug output defines
Date: Fri, 12 Jan 2007 16:37:43 -0800
Message-ID: <20070113003743.16816.8364.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1196 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161167AbXAMAyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:10 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove unused MSGOUT macro and add "\n" to function debug output.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_osdep.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 18afc0c..10af742 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -48,8 +48,6 @@ typedef enum {
     TRUE = 1
 } boolean_t;
 
-#define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
-
 #ifdef DBG
 #define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
 #define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
@@ -58,7 +56,7 @@ typedef enum {
 #define DEBUGOUT1(S, A...)
 #endif
 
-#define DEBUGFUNC(F) DEBUGOUT(F)
+#define DEBUGFUNC(F) DEBUGOUT(F "\n")
 #define DEBUGOUT2 DEBUGOUT1
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3



---
Auke Kok <auke-jan.h.kok@intel.com>
