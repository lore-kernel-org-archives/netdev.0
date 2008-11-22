From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: update DCA comments
Date: Sat, 22 Nov 2008 10:23:02 +0100
Message-ID: <4927CF76.7080407@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1797 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751072AbYKVJXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:23:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update DCA sections closing comments.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-11-22 10:06:58.000000000 +0100
+++ net-next-2.6/drivers/net/myri10ge/myri10ge.c	2008-11-22 09:53:31.000000000 +0100
@@ -1024,7 +1024,7 @@
 			ss->dca_tag = NULL;
 		}
 	}
-#endif				/* CONFIG_DCA */
+#endif				/* CONFIG_MYRI10GE_DCA */
 
 	/* reset mcp/driver shared state back to 0 */
 
@@ -1121,7 +1121,7 @@
 		myri10ge_teardown_dca(mgp);
 	return 0;
 }
-#endif				/* CONFIG_DCA */
+#endif				/* CONFIG_MYRI10GE_DCA */
 
 static inline void
 myri10ge_submit_8rx(struct mcp_kreq_ether_recv __iomem * dst,
@@ -4027,7 +4026,7 @@
 	.next = NULL,
 	.priority = 0,
 };
-#endif				/* CONFIG_DCA */
+#endif				/* CONFIG_MYRI10GE_DCA */
 
 static __init int myri10ge_init_module(void)
 {


