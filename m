From: Matthew Galgoci <mgalgoci@redhat.com>
Subject: [patch] kill warning in sk98lin
Date: Fri, 27 Aug 2004 21:18:57 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408272116540.16018-100000@lacrosse.corp.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix up a warning in sk98lin:

--- drivers/net/sk98lin/skge.c.orig	2004-08-27 21:01:33.447576657 -0400
+++ drivers/net/sk98lin/skge.c	2004-08-27 21:06:07.199406778 -0400
@@ -788,8 +788,9 @@
 	cards = skge_probe();
 	if (cards == 0) {
 		printk("sk98lin: No adapter found.\n");
+		cards = -ENODEV;
 	}
-	return cards ? 0 : -ENODEV;
+	return cards;
 } /* skge_init_module */
 
 

-- 
Matthew Galgoci
System Administrator and Sr. Manager of Ruminants
Red Hat, Inc
919.754.3700 x44155
