From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] add annotation to sock_filter.h
Date: Thu, 17 Jun 2004 10:26:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617102622.5f07fc56@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since sock_fprog is argument in ioctl, the filter pointer needs to be annotated.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/filter.h b/include/linux/filter.h
--- a/include/linux/filter.h	2004-06-16 15:26:32 -07:00
+++ b/include/linux/filter.h	2004-06-16 15:26:32 -07:00
@@ -5,6 +5,8 @@
 #ifndef __LINUX_FILTER_H__
 #define __LINUX_FILTER_H__
 
+#include <linux/compiler.h>
+
 /*
  * Current version of the filter code architecture.
  */
@@ -27,7 +29,7 @@
 struct sock_fprog	/* Required for SO_ATTACH_FILTER. */
 {
 	unsigned short		len;	/* Number of filter blocks */
-	struct sock_filter	*filter;
+	struct sock_filter __user *filter;
 };
 
 #ifdef __KERNEL__
