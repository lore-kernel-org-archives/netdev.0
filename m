From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] remove unused function prototype
Date: Mon, 18 Aug 2003 11:22:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818112215.312fb201.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Unused function prototype defined but never used on 2.6.0-test3

diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Mon Aug 18 11:12:00 2003
+++ b/net/irda/irda_device.c	Mon Aug 18 11:12:00 2003
@@ -83,12 +83,6 @@
 
 static void irda_task_timer_expired(void *data);
 
-#ifdef CONFIG_PROC_FS
-int irda_device_proc_read(char *buf, char **start, off_t offset, int len,
-			  int unused);
-
-#endif /* CONFIG_PROC_FS */
-
 int __init irda_device_init( void)
 {
 	dongles = hashbin_new(HB_LOCK);
