From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/8] dcbnl: Use type safe nlmsg_data()
Date: Wed, 13 Jun 2012 14:55:01 +0200
Message-ID: <d5943ea9c16f07d7e8b4ea86038d77cd3c261024.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753802Ab2FMMzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:17 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 6e1c324..70bba3e 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1659,7 +1659,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *netdev;
-	struct dcbmsg  *dcb = (struct dcbmsg *)NLMSG_DATA(nlh);
+	struct dcbmsg *dcb = nlmsg_data(nlh);
 	struct nlattr *tb[DCB_ATTR_MAX + 1];
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = -EINVAL;
-- 
1.7.7.6
