From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 10/14] e1000: Kernel API change for Module_param_array_named
Date: Thu, 6 Jan 2005 17:21:52 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061533590.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_param.c net-drivers-2.6/drivers/net/e1000.new/e1000_param.c
--- net-drivers-2.6/drivers/net/e1000/e1000_param.c	2004-12-03 07:24:37.091623032 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_param.c	2004-12-03 07:24:38.662384240 -0800
@@ -47,7 +47,7 @@
 #define E1000_PARAM(X, desc) \
 	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
 	static int num_##X = 0; \
-	module_param_array(X, int, &num_##X, 0); \
+	module_param_array_named(X, X, int, &num_##X, 0); \
 	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count
