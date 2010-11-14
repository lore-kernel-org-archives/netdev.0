From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: define ct_*_info as needed
Date: Sun, 14 Nov 2010 14:40:13 +0800
Message-ID: <1289716813-30822-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/netfilter/nf_conntrack.h |   13 +++++++++++++
 1 file changed, 13 insertions(+)
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index caf17db..25c34af 100644
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
