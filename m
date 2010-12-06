From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH] l2tp: Fix modalias of l2tp_ip
Date: Mon,  6 Dec 2010 13:39:12 +0100
Message-ID: <1291639152-26608-1-git-send-email-mmarek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the SOCK_DGRAM enum results in
"net-pf-2-proto-SOCK_DGRAM-type-115", so use the numeric value like it
is done in net/dccp.

Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 net/l2tp/l2tp_ip.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 0bf6a59..522e219 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -674,4 +674,8 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("L2TP over IP");
 MODULE_VERSION("1.0");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET, SOCK_DGRAM, IPPROTO_L2TP);
+
+/* Use the value of SOCK_DGRAM (2) directory, because __stringify does't like
+ * enums
+ */
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET, 2, IPPROTO_L2TP);
-- 
1.7.3.1
