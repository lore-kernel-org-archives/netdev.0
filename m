From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 2/5] netfilter: Fix format string mismatch in mangle_content_len()
Date: Tue,  1 Apr 2014 00:43:36 +0900
Message-ID: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix format string mismatch in mangle_connect_len()

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/netfilter/nf_nat_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index b4d691d..5f98845 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -434,7 +434,7 @@ static int mangle_content_len(struct sk_buff *skb, unsigned int protoff,
 			      &matchoff, &matchlen) <= 0)
 		return 0;
 
-	buflen = sprintf(buffer, "%u", c_len);
+	buflen = sprintf(buffer, "%d", c_len);
 	return mangle_packet(skb, protoff, dataoff, dptr, datalen,
 			     matchoff, matchlen, buffer, buflen);
 }
-- 
1.9.1.352.gd393d14
