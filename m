From: akpm@linux-foundation.org
Subject: [patch 02/11] net/irda/: proper prototypes
Date: Mon, 05 Feb 2007 16:30:53 -0800
Message-ID: <200702060031.l160VuqL004621@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de,
	samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41479 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965164AbXBFAc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

Add proper prototypes for some functions in include/net/irda/irda.h

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/irda/irda.h |   15 +++++++++++++++
 net/irda/irmod.c        |   13 -------------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff -puN include/net/irda/irda.h~net-irda-proper-prototypes include/net/irda/irda.h
--- a/include/net/irda/irda.h~net-irda-proper-prototypes
+++ a/include/net/irda/irda.h
@@ -113,4 +113,19 @@ do { if(!(expr)) { \
 #define IAS_IRCOMM_ID 0x2343
 #define IAS_IRLPT_ID  0x9876
 
+struct net_device;
+struct packet_type;
+
+void irda_proc_register(void);
+void irda_proc_unregister(void);
+
+int irda_sysctl_register(void);
+void irda_sysctl_unregister(void);
+
+int irsock_init(void);
+void irsock_cleanup(void);
+
+int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
+		     struct packet_type *ptype, struct net_device *orig_dev);
+
 #endif /* NET_IRDA_H */
diff -puN net/irda/irmod.c~net-irda-proper-prototypes net/irda/irmod.c
--- a/net/irda/irmod.c~net-irda-proper-prototypes
+++ a/net/irda/irmod.c
@@ -42,19 +42,6 @@
 #include <net/irda/irttp.h>		/* irttp_init */
 #include <net/irda/irda_device.h>	/* irda_device_init */
 
-/* irproc.c */
-extern void irda_proc_register(void);
-extern void irda_proc_unregister(void);
-/* irsysctl.c */
-extern int  irda_sysctl_register(void);
-extern void irda_sysctl_unregister(void);
-/* af_irda.c */
-extern int  irsock_init(void);
-extern void irsock_cleanup(void);
-/* irlap_frame.c */
-extern int  irlap_driver_rcv(struct sk_buff *, struct net_device *, 
-			     struct packet_type *, struct net_device *);
-
 /*
  * Module parameters
  */
_
