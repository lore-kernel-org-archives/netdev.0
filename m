From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/irda/: proper prototypes
Date: Mon, 18 Dec 2006 04:46:26 +0100
Message-ID: <20061218034626.GY10316@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:4283 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752711AbWLRDq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 22:46:26 -0500
To: samuel@sortiz.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds proper prototypes for some functions in
include/net/irda/irda.h

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/irda/irda.h |   15 +++++++++++++++
 net/irda/irmod.c        |   13 -------------
 2 files changed, 15 insertions(+), 13 deletions(-)

--- linux-2.6.20-rc1-mm1/include/net/irda/irda.h.old	2006-12-18 02:49:02.000000000 +0100
+++ linux-2.6.20-rc1-mm1/include/net/irda/irda.h	2006-12-18 02:58:02.000000000 +0100
@@ -113,4 +113,19 @@
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
--- linux-2.6.20-rc1-mm1/net/irda/irmod.c.old	2006-12-18 02:52:18.000000000 +0100
+++ linux-2.6.20-rc1-mm1/net/irda/irmod.c	2006-12-18 02:53:59.000000000 +0100
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

