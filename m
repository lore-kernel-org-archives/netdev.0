From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 9/13] e1000: Sparse cleanup - shemminger@osdl.org
Date: Thu, 6 Jan 2005 17:20:09 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061509250.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000.h net-drivers-2.4/drivers/net/e1000.new/e1000.h
--- net-drivers-2.4/drivers/net/e1000/e1000.h	2004-12-06 08:43:11.624383592 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000.h	2004-12-06 08:43:12.400265640 -0800
@@ -86,7 +86,7 @@ struct e1000_adapter;
 
 #include "e1000_hw.h"
 
-#if DBG
+#ifdef DBG
 #define E1000_DBG(args...) printk(KERN_DEBUG "e1000: " args)
 #else
 #define E1000_DBG(args...)
diff -up net-drivers-2.4/drivers/net/e1000/e1000_osdep.h net-drivers-2.4/drivers/net/e1000.new/e1000_osdep.h
--- net-drivers-2.4/drivers/net/e1000/e1000_osdep.h	2004-12-06 08:43:11.635381920 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_osdep.h	2004-12-06 08:43:12.576238888 -0800
@@ -69,7 +69,7 @@ typedef enum {
 
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
 
-#if DBG
+#ifdef DBG
 #define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
 #define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
 #else
