From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/7) ipmr - C99 initializers
Date: Wed, 25 Jun 2003 11:40:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114042.3cee041e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change notifier to C99 initialization

This one changes an initializer to C99 style.
diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:14:59 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:14:59 2003
@@ -1078,9 +1078,7 @@
 
 
 static struct notifier_block ip_mr_notifier={
-	ipmr_device_event,
-	NULL,
-	0
+	.notifier_call = ipmr_device_event,
 };
 
 /*
