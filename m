From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/42) at1500
Date: Wed, 12 Nov 2003 16:41:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130041.hAD0fcM30165@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on viro NE32-at1500
	ROTFL.  The last remnants of CONFIG_AT1500 removed - that was a hell
	of an ancient bug (at1500_probe() was never defined, AFAICS - all
	way back to 0.99.15).

diff -Nru a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	Tue Nov 11 09:35:42 2003
+++ b/drivers/net/Makefile	Tue Nov 11 09:35:42 2003
@@ -111,7 +111,6 @@
 obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
-obj-$(CONFIG_AT1500) += lance.o
 obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_SUN3LANCE) += sun3lance.o
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 09:35:42 2003
+++ b/drivers/net/Space.c	Tue Nov 11 09:35:42 2003
@@ -51,7 +51,6 @@
 extern int hp_plus_probe(struct net_device *dev);
 extern struct net_device *express_probe(int unit);
 extern struct net_device *eepro_probe(int unit);
-extern int at1500_probe(struct net_device *);
 extern struct net_device *at1700_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
@@ -234,9 +233,6 @@
 #endif
 #ifdef CONFIG_SEEQ8005 
 	{seeq8005_probe, 0},
-#endif
-#ifdef CONFIG_AT1500
-	{at1500_probe, 0},
 #endif
 	{NULL, 0},
 };
