From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] unneeded proc_fs.h includes in packet schedulers
Date: Fri, 5 Sep 2003 13:59:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905135935.682936bc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Following include proc_fs.h but don't use it.

diff -Nru a/net/sched/estimator.c b/net/sched/estimator.c
--- a/net/sched/estimator.c	Fri Sep  5 13:57:10 2003
+++ b/net/sched/estimator.c	Fri Sep  5 13:57:10 2003
@@ -26,7 +26,6 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	Fri Sep  5 13:57:10 2003
+++ b/net/sched/police.c	Fri Sep  5 13:57:10 2003
@@ -27,7 +27,6 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
-#include <linux/proc_fs.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
