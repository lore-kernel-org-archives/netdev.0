From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 6/6] tipc: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:04:20 -0700
Message-ID: <3f2447bc68b2fce7aa854eca0f6a1e263ec3669a.1394643455.git.joe@perches.com>
References: <cover.1394643455.git.joe@perches.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 89c4c2d..7f1f95c 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -575,7 +575,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 }
 
 static struct packet_type tipc_packet_type __read_mostly = {
-	.type = __constant_htons(ETH_P_TIPC),
+	.type = htons(ETH_P_TIPC),
 	.func = tipc_l2_rcv_msg,
 };
 
-- 
1.8.1.2.459.gbcd45b4.dirty
