From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/11] PKT_SCHED: linux/pkt_cls.h depends on linux/pkt_sched.h
Date: Wed, 27 Oct 2004 00:22:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222232.GB12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.6.10-rc1-bk1.orig/include/linux/pkt_cls.h	2004-10-24 10:58:48.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/linux/pkt_cls.h	2004-10-24 15:02:28.000000000 +0200
@@ -1,6 +1,8 @@
 #ifndef __LINUX_PKT_CLS_H
 #define __LINUX_PKT_CLS_H
 
+#include <linux/pkt_sched.h>
+
 /* I think i could have done better macros ; for now this is stolen from
  * some arch/mips code - jhs
 */
