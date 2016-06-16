From: Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] net: do not initialise statics to 0
Date: Thu, 16 Jun 2016 21:17:49 +0800
Message-ID: <1466083069-9603-1-git-send-email-tangwei@cmss.chinamobile.com>
Cc: ast@plumgrid.com, tom@herbertland.com, daniel@iogearbox.net,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wei Tang <tangwei@cmss.chinamobile.com>
To: davem@davemloft.net, edumazet@google.com, aduyck@mirantis.com,
	jiri@mellanox.com, jarod@redhat.com, nikolay@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the checkpatch.pl error to dev.c:

ERROR: do not initialise statics to 0

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff43..7a3fe58 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2420,7 +2420,7 @@ EXPORT_SYMBOL(__skb_tx_hash);
 
 static void skb_warn_bad_offload(const struct sk_buff *skb)
 {
-	static const netdev_features_t null_features = 0;
+	static const netdev_features_t null_features;
 	struct net_device *dev = skb->dev;
 	const char *name = "";
 
-- 
1.9.1
