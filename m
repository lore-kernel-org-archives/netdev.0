From: linzhang <xiaolou4617@gmail.com>
Subject: [PATCH] net: netfilter: netlink: delete extra spaces
Date: Fri, 12 May 2017 13:11:06 +0800
Message-ID: <1494565866-23308-1-git-send-email-xiaolou4617@gmail.com>
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linzhang <xiaolou4617@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleans up extra spaces.

Signed-off-by: linzhang <xiaolou4617@gmail.com>
---
 net/netfilter/nf_conntrack_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index dcf561b..356e6f0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -634,11 +634,11 @@ static size_t ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	if (events & (1 << IPCT_DESTROY)) {
 		type = IPCTNL_MSG_CT_DELETE;
 		group = NFNLGRP_CONNTRACK_DESTROY;
-	} else  if (events & ((1 << IPCT_NEW) | (1 << IPCT_RELATED))) {
+	} else if (events & ((1 << IPCT_NEW) | (1 << IPCT_RELATED))) {
 		type = IPCTNL_MSG_CT_NEW;
 		flags = NLM_F_CREATE|NLM_F_EXCL;
 		group = NFNLGRP_CONNTRACK_NEW;
-	} else  if (events) {
+	} else if (events) {
 		type = IPCTNL_MSG_CT_NEW;
 		group = NFNLGRP_CONNTRACK_UPDATE;
 	} else
-- 
1.8.3.1
