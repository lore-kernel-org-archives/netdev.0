From: matt mooney <mfm@muteddisk.com>
Subject: [PATCH 20/20] net: change to new flag variable
Date: Wed, 22 Sep 2010 23:51:55 -0700
Message-ID: <1285224715-30137-1-git-send-email-mfm@muteddisk.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace EXTRA_CFLAGS with ccflags-y.

Signed-off-by: matt mooney <mfm@muteddisk.com>
---
 net/caif/Makefile |    4 +---
 net/rds/Makefile  |    4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/caif/Makefile b/net/caif/Makefile
index f87481f..38581ba 100644
--- a/net/caif/Makefile
+++ b/net/caif/Makefile
@@ -1,6 +1,4 @@
-ifeq ($(CONFIG_CAIF_DEBUG),y)
-EXTRA_CFLAGS += -DDEBUG
-endif
+ccflags-$(CONFIG_CAIF_DEBUG) := -DDEBUG
 
 caif-objs := caif_dev.o \
 	cfcnfg.o cfmuxl.o cfctrl.o  \
diff --git a/net/rds/Makefile b/net/rds/Makefile
index b46eca1..f00fb19 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -15,7 +15,5 @@ obj-$(CONFIG_RDS_TCP) += rds_tcp.o
 rds_tcp-objs :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
 			tcp_send.o tcp_stats.o
 
-ifeq ($(CONFIG_RDS_DEBUG), y)
-EXTRA_CFLAGS += -DDEBUG
-endif
+ccflags-$(CONFIG_RDS_DEBUG) := -DDEBUG
 
-- 
1.7.2.1
