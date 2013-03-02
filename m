From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] caif_dev: fix sparse warnings for caif_flow_cb
Date: Sat,  2 Mar 2013 21:45:19 +0200
Message-ID: <1362253519-13014-1-git-send-email-silviupopescu1990@gmail.com>
Cc: sjur.brandeland@stericsson.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixed the following sparse warning:
net/caif/caif_dev.c:121:6: warning: symbol 'caif_flow_cb' was not
declared. Should it be static?

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 net/caif/caif_dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 1ae1d9c..21760f0 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -118,7 +118,7 @@ static struct caif_device_entry *caif_get(struct net_device *dev)
 	return NULL;
 }
 
-void caif_flow_cb(struct sk_buff *skb)
+static void caif_flow_cb(struct sk_buff *skb)
 {
 	struct caif_device_entry *caifd;
 	void (*dtor)(struct sk_buff *skb) = NULL;
-- 
1.7.9.5
