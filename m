From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net-next 7/9] netfilter: Always export nf_connlabels_replace()
Date: Tue,  4 Aug 2015 21:49:57 -0700
Message-ID: <1438750199-9061-8-git-send-email-joestringer@nicira.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches will reuse this code from OVS.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/netfilter/nf_conntrack_labels.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index 06e71a0..3ce5c31 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -50,7 +50,6 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 }
 EXPORT_SYMBOL_GPL(nf_connlabel_set);
 
-#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 static void replace_u32(u32 *address, u32 mask, u32 new)
 {
 	u32 old, tmp;
@@ -91,7 +90,6 @@ int nf_connlabels_replace(struct nf_conn *ct,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_connlabels_replace);
-#endif
 
 int nf_connlabels_get(struct net *net, unsigned int n_bits)
 {
-- 
2.1.4
