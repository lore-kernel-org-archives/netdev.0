From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] 1/3 rtnetlink -- rtattr_strcmp const args.
Date: Mon, 22 Sep 2003 16:35:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922163515.2cfd254e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

trivial, rtattr_strcmp doesn't modify its arguments

diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	Mon Sep 22 15:53:29 2003
+++ b/include/linux/rtnetlink.h	Mon Sep 22 15:53:29 2003
@@ -618,7 +618,7 @@
 
 #include <linux/config.h>
 
-static __inline__ int rtattr_strcmp(struct rtattr *rta, char *str)
+static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
 {
 	int len = strlen(str) + 1;
 	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);
