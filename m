From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/3 net-2.6.26] [NETNS]: Remove ifdef CONFIG_NET braces in fs/proc/proc_net.c.
Date: Mon, 31 Mar 2008 19:47:01 +0400
Message-ID: <1206978422-13088-2-git-send-email-den@openvz.org>
References: <1206978361.10660.31.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24764 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbYCaPrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 11:47:11 -0400
In-Reply-To: <1206978361.10660.31.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are redundant as this file is linked in iff CONFIG_NET is turned on.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 fs/proc/proc_net.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 7034fac..13cd783 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -51,7 +51,6 @@ int seq_open_net(struct inode *ino, struct file *f,
 }
 EXPORT_SYMBOL_GPL(seq_open_net);
 
-#ifdef CONFIG_NET
 int seq_release_net(struct inode *ino, struct file *f)
 {
 	struct seq_file *seq;
@@ -219,4 +218,3 @@ int __init proc_net_init(void)
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
-#endif /* CONFIG_NET */
-- 
1.5.3.rc5

