From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] missing __KERNEL__ ifdef in include/linux/device.h
Date: Sun, 20 Jul 2003 04:55:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030720025528.GA30577@rei.rakuen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

device.h should be protected with __KERNEL__ because it uses
__KERNEL__ protected structures. Userspace applications
including if_arp.h such as iproute2 will fail because
it finally includes device.h as well.

 - thomas


Index: include/linux/device.h
===================================================================
RCS file: /cvs/tgr/linux-25/include/linux/device.h,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 device.h
--- include/linux/device.h	10 Jul 2003 22:58:31 -0000	1.1.1.2
+++ include/linux/device.h	20 Jul 2003 02:49:12 -0000
@@ -8,7 +8,7 @@
  * See Documentation/driver-model/ for more information.
  */
 
-#ifndef _DEVICE_H_
+#if defined __KERNEL__ && !defined _DEVICE_H_
 #define _DEVICE_H_
 
 #include <linux/config.h>
