From: pablo@netfilter.org
Subject: [PATCH 2/7] netfilter: xt_conntrack: Add flag to support aliases
Date: Tue, 19 Feb 2013 01:10:46 +0100
Message-ID: <1361232651-5626-3-git-send-email-pablo@netfilter.org>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The patch adds the flag to denote the "state" alias as of the subset
of the "conntrack" match.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_conntrack.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/netfilter/xt_conntrack.h b/include/uapi/linux/netfilter/xt_conntrack.h
index e3c041d..e5bd308 100644
--- a/include/uapi/linux/netfilter/xt_conntrack.h
+++ b/include/uapi/linux/netfilter/xt_conntrack.h
@@ -31,6 +31,7 @@ enum {
 	XT_CONNTRACK_REPLSRC_PORT = 1 << 10,
 	XT_CONNTRACK_REPLDST_PORT = 1 << 11,
 	XT_CONNTRACK_DIRECTION    = 1 << 12,
+	XT_CONNTRACK_STATE_ALIAS  = 1 << 13,
 };
 
 struct xt_conntrack_mtinfo1 {
-- 
1.7.10.4

