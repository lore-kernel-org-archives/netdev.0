From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] dcbnl: Silence harmless gcc warning about uninitialized
 reply_nlh
Date: Thu, 14 Jun 2012 04:34:03 -0400
Message-ID: <20120614083403.GB29738@canuck.infradead.org>
References: <4fd9474c.wdaRvq8n+Xh/6wOA%wfg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wfg@linux.intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38366 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab2FNIeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 04:34:04 -0400
Content-Disposition: inline
In-Reply-To: <4fd9474c.wdaRvq8n+Xh/6wOA%wfg@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 70bba3e..da6ee81 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1664,7 +1664,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = -EINVAL;
 	struct sk_buff *reply_skb;
-	struct nlmsghdr *reply_nlh;
+	struct nlmsghdr *reply_nlh = NULL;
 	const struct reply_func *fn;
 
 	if (!net_eq(net, &init_net))
