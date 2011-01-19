From: kaber@trash.net
Subject: [PATCH 05/79] netfilter: nf_conntrack: define ct_*_info as needed
Date: Wed, 19 Jan 2011 20:14:05 +0100
Message-ID: <1295464519-21763-6-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index abfff1e..8a58901 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -50,11 +50,24 @@ union nf_conntrack_expect_proto {
 /* per conntrack: application helper private data */
 union nf_conntrack_help {
 	/* insert conntrack helper private data (master) here */
+#if defined(CONFIG_NF_CONNTRACK_FTP) || defined(CONFIG_NF_CONNTRACK_FTP_MODULE)
 	struct nf_ct_ftp_master ct_ftp_info;
+#endif
+#if defined(CONFIG_NF_CONNTRACK_PPTP) || \
+    defined(CONFIG_NF_CONNTRACK_PPTP_MODULE)
 	struct nf_ct_pptp_master ct_pptp_info;
+#endif
+#if defined(CONFIG_NF_CONNTRACK_H323) || \
+    defined(CONFIG_NF_CONNTRACK_H323_MODULE)
 	struct nf_ct_h323_master ct_h323_info;
+#endif
+#if defined(CONFIG_NF_CONNTRACK_SANE) || \
+    defined(CONFIG_NF_CONNTRACK_SANE_MODULE)
 	struct nf_ct_sane_master ct_sane_info;
+#endif
+#if defined(CONFIG_NF_CONNTRACK_SIP) || defined(CONFIG_NF_CONNTRACK_SIP_MODULE)
 	struct nf_ct_sip_master ct_sip_info;
+#endif
 };
 
 #include <linux/types.h>
-- 
1.7.2.3

