From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test4 SEQ_START_TOKEN arch/* (3/6)
Date: Fri, 05 Sep 2003 18:47:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062812848.16851.167.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN linux-2.6.0-test4/arch/arm/kernel/setup.c SEQ_START_TOKEN/arch/arm/kernel/setup.c
-- linux-2.6.0-test4/arch/arm/kernel/setup.c	2003-08-22 16:56:28.000000000 -0700
+++ SEQ_START_TOKEN/arch/arm/kernel/setup.c	2003-09-04 19:47:27.000000000 -0700
@@ -824,7 +824,7 @@
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < 1 ? (void *)1 : NULL;
+	return *pos < 1 ? SEQ_START_TOKEN : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
diff -urN linux-2.6.0-test4/arch/arm26/kernel/setup.c SEQ_START_TOKEN/arch/arm26/kernel/setup.c
-- linux-2.6.0-test4/arch/arm26/kernel/setup.c	2003-09-02 12:52:32.000000000 -0700
+++ SEQ_START_TOKEN/arch/arm26/kernel/setup.c	2003-09-04 19:47:50.000000000 -0700
@@ -537,7 +537,7 @@
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < 1 ? (void *)1 : NULL;
+	return *pos < 1 ? SEQ_START_TOKEN : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
diff -urN linux-2.6.0-test4/arch/cris/kernel/setup.c SEQ_START_TOKEN/arch/cris/kernel/setup.c
-- linux-2.6.0-test4/arch/cris/kernel/setup.c	2003-08-22 16:59:39.000000000 -0700
+++ SEQ_START_TOKEN/arch/cris/kernel/setup.c	2003-09-04 19:47:55.000000000 -0700
@@ -170,7 +170,7 @@
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
 	/* We only got one CPU... */
-	return *pos < 1 ? (void *)1 : NULL;
+	return *pos < 1 ? SEQ_START_TOKEN : NULL;
 }
 
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
diff -urN linux-2.6.0-test4/arch/m68k/kernel/setup.c SEQ_START_TOKEN/arch/m68k/kernel/setup.c
-- linux-2.6.0-test4/arch/m68k/kernel/setup.c	2003-08-22 17:00:51.000000000 -0700
+++ SEQ_START_TOKEN/arch/m68k/kernel/setup.c	2003-09-04 19:47:42.000000000 -0700
@@ -480,7 +480,7 @@
 
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
-	return *pos < 1 ? (void *)1 : NULL;
+	return *pos < 1 ? SEQ_START_TOKEN : NULL;
 }
 static void *c_next(struct seq_file *m, void *v, loff_t *pos)
 {
diff -urN linux-2.6.0-test4/arch/parisc/kernel/setup.c SEQ_START_TOKEN/arch/parisc/kernel/setup.c
-- linux-2.6.0-test4/arch/parisc/kernel/setup.c	2003-08-22 17:01:28.000000000 -0700
+++ SEQ_START_TOKEN/arch/parisc/kernel/setup.c	2003-09-04 19:47:04.000000000 -0700
@@ -163,7 +163,7 @@
 	 * through CPUs for example.  Since we print all cpu info in our
 	 * show_cpuinfo() disregarding 'pos' (which I assume is 'v' above)
 	 * we only allow for one "position".  */
-	return ((long)*pos < 1) ? (void *)1 : NULL;
+	return ((long)*pos < 1) ? SEQ_START_TOKEN : NULL;
 }
 
 static void *
