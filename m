From: Lucas Tanure <tanure@linux.com>
Subject: [PATCH 1/4] netfilter: ipv4: use linux/uaccess.h
Date: Sat, 30 Jan 2016 11:17:55 -0200
Message-ID: <1454159878-20706-1-git-send-email-tanure@linux.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch warning
WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

Signed-off-by: Lucas Tanure <tanure@linux.com>
---
 net/ipv4/netfilter/ip_tables.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b99affa..aa0e41e 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -20,7 +20,7 @@
 #include <linux/icmp.h>
 #include <net/ip.h>
 #include <net/compat.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/mutex.h>
 #include <linux/proc_fs.h>
 #include <linux/err.h>
-- 
2.7.0
