From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test4 SEQ_START_TOKEN Add #define to seq_file.h (1/6)
Date: Fri, 05 Sep 2003 18:46:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062812809.16845.163.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Code that includes seq_file.h use a magic pointer "(void*)1"
to start a header seq_printf.

These patches convert the magic pointer use to a #define

diff -urN linux-2.6.0-test4/include/linux/seq_file.h SEQ_START_TOKEN/include/linux/seq_file.h
-- linux-2.6.0-test4/include/linux/seq_file.h	2003-08-22 17:02:49.000000000 -0700
+++ SEQ_START_TOKEN/include/linux/seq_file.h	2003-09-04 17:28:19.000000000 -0700
@@ -65,5 +65,8 @@
 int single_open(struct file *, int (*)(struct seq_file *, void *), void *);
 int single_release(struct inode *, struct file *);
 int seq_release_private(struct inode *, struct file *);
+
+#define SEQ_START_TOKEN ((void *)1)
+
 #endif
 #endif
