From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: e1000 compilation broken in 2.6.10-rc1
Date: Thu, 28 Oct 2004 14:08:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410281405560.28397-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff:

e1000/e1000_param.c needs the change below in order to compile correctly 
in 2.6.10-rc1 and beyond.

--- /netdev-2.6/drivers/net/e1000/e1000_param.c	2004-10-28 13:41:22.972953056 -0700
+++ /netdev-2.6.new/drivers/net/e1000/e1000_param.c	2004-10-28 13:41:03.361934384 -0700
@@ -47,7 +47,7 @@
 #define E1000_PARAM(X, desc) \
 	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
 	static int num_##X = 0; \
-	module_param_array(X, int, num_##X, 0); \
+	module_param_array(X, int, &num_##X, 0); \
 	MODULE_PARM_DESC(X, desc);
 
 /* Transmit Descriptor Count

thanks,
ganesh.
