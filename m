From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/38] netfilter: ipset: Prepare the kernel for create option flags when no extension is needed
Date: Mon, 17 Mar 2014 13:42:34 +0100
Message-ID: <1395060178-11833-15-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |    2 ++
 include/uapi/linux/netfilter/ipset/ip_set.h |    6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 4ac00d4..f476bce 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -219,6 +219,8 @@ struct ip_set {
 	u8 revision;
 	/* Extensions */
 	u8 extensions;
+	/* Create flags */
+	u8 flags;
 	/* Default timeout value, if enabled */
 	u32 timeout;
 	/* Element data size */
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index f636f28..a29a378 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -188,6 +188,12 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_CADT_MAX	= 15,
 };
 
+/* The flag bits which correspond to the non-extension create flags */
+enum ipset_create_flags {
+	IPSET_CREATE_FLAG_NONE = 0,
+	IPSET_CREATE_FLAG_MAX = 7,
+};
+
 /* Commands with settype-specific attributes */
 enum ipset_adt {
 	IPSET_ADD,
-- 
1.7.10.4

