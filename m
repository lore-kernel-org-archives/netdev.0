From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/11] PKT_SCHED: psched_*_per_* can be static
Date: Wed, 27 Oct 2004 00:27:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222737.GI12289@postel.suug.ch>
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

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/net/sched/sch_api.c	2004-10-26 23:36:12.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/sch_api.c	2004-10-26 23:36:47.000000000 +0200
@@ -1145,8 +1145,8 @@
 	return -1;
 }
 
-int psched_us_per_tick = 1;
-int psched_tick_per_us = 1;
+static int psched_us_per_tick = 1;
+static int psched_tick_per_us = 1;
 
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
