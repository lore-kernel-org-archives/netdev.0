From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/6) ipvs -- get rid of SEQ_START_TOKEN define
Date: Tue, 16 Sep 2003 14:17:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916141731.276de60c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Applies to 2.6.0-test5 with my seq_file patches from yesterday.

Get rid of SEQ_START_TOKEN -- already defined in proc_fs.hdiff -Nru a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
--- a/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:08:11 2003
+++ b/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:08:11 2003
@@ -485,8 +485,6 @@
 /*
  *	/proc/net/ip_vs_app entry function
  */
-#define SEQ_START_TOKEN	((void *)1)
-
 static struct ip_vs_app *ip_vs_app_idx(loff_t pos)
 {
 	loff_t off = 0;
diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
--- a/net/ipv4/ipvs/ip_vs_conn.c	Tue Sep 16 14:08:11 2003
+++ b/net/ipv4/ipvs/ip_vs_conn.c	Tue Sep 16 14:08:11 2003
@@ -616,8 +616,6 @@
  */
 #ifdef CONFIG_PROC_FS
 
-#define SEQ_START_TOKEN	((void *)1)
-
 static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 {
 	struct list_head *e;
diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
--- a/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:11 2003
+++ b/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:11 2003
@@ -1516,8 +1516,6 @@
 	int bucket;
 };
 
-
-#define SEQ_START_TOKEN	((void *)1)
 /*
  *	Write the contents of the VS rule table to a PROCfs file.
  *	(It is kept just for backward compatibility)
