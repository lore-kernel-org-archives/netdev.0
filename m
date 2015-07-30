From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next 7/9] netfilter: Always export nf_connlabels_replace()
Date: Thu, 30 Jul 2015 11:12:41 -0700
Message-ID: <1438279963-29563-8-git-send-email-joestringer@nicira.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, jpettit@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, jesse@nicira.com,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@noironetworks.com
To: netdev@vger.kernel.org, pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches will reuse this code from OVS.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/netfilter/nf_conntrack_labels.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index bb53f12..daa7c13 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -48,7 +48,6 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 }
 EXPORT_SYMBOL_GPL(nf_connlabel_set);
 
-#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 static void replace_u32(u32 *address, u32 mask, u32 new)
 {
 	u32 old, tmp;
@@ -89,7 +88,6 @@ int nf_connlabels_replace(struct nf_conn *ct,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_connlabels_replace);
-#endif
 
 static struct nf_ct_ext_type labels_extend __read_mostly = {
 	.len    = sizeof(struct nf_conn_labels),
-- 
2.1.4
