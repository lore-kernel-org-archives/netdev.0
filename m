From: Joe Perches <joe@perches.com>
Subject: [PATCH] irda: Simplify IRDA logging macros
Date: Tue, 11 Nov 2014 13:13:41 -0800
Message-ID: <1415740421.16070.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0029.hostedemail.com ([216.40.44.29]:56209 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751412AbaKKVNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:13:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are the same as net_<level>_ratelimited, so
use the more common style in the macro definition.

Signed-off-by: Joe Perches <joe@perches.com>
---

I wonder if the IRDA_ macro uses should be converted
directly instead but that diffstat is quite a bit
longer than this one
 42 files changed, 486 insertions(+), 479 deletions(-)
vs
 include/net/irda/irda.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index a059465..42aa054 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -77,9 +77,9 @@ do { if(!(expr)) { \
 #define IRDA_ASSERT_LABEL(label)
 #endif /* CONFIG_IRDA_DEBUG */
 
-#define IRDA_WARNING(args...) do { if (net_ratelimit()) printk(KERN_WARNING args); } while (0)
-#define IRDA_MESSAGE(args...) do { if (net_ratelimit()) printk(KERN_INFO args); } while (0)
-#define IRDA_ERROR(args...)   do { if (net_ratelimit()) printk(KERN_ERR args); } while (0)
+#define IRDA_ERROR		net_err_ratelimited
+#define IRDA_WARNING		net_warn_ratelimited
+#define IRDA_MESSAGE		net_info_ratelimited
 
 /*
  *  Magic numbers used by Linux-IrDA. Random numbers which must be unique to 
