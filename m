From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: [patch] 2.4 lacks dummy SET_NETDEV_DEV
Date: Mon, 10 Nov 2003 20:19:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110181917.GA25846@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just noticed that 2.4 doesn't have a dummy SET_NETDEV_DEV for drivers
written for 2.6 (like the b44 fixes that got merged a few days back, so
it wouldn't actually compile :-) )

--- linux-2.4.22/include/linux/netdevice.h.orig 2003-10-03 20:30:14.000000000 +0300
+++ linux-2.4.22/include/linux/netdevice.h      2003-11-10 20:12:46.480609408 +0200
@@ -454,6 +454,8 @@
 #endif /* CONFIG_NET_DIVERT */
 };
  
+/* 2.6 compatibility */
+#define SET_NETDEV_DEV(net, pdev) do { } while (0)
  
 struct packet_type
 {
