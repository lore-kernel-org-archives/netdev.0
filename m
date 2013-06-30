From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/12] kernel: remove unnecessary head file
Date: Mon,  1 Jul 2013 01:54:39 +0200
Message-ID: <1372636481-3705-11-git-send-email-pablo@netfilter.org>
References: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59887 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab3F3XzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 19:55:01 -0400
In-Reply-To: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: JunweiZhang <junwei.zhang@6wind.com>

ip_vs.h is not necessary for sysctl_binary.c.

prepare for the next patch to avoid compile issue.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reviewed-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 kernel/sysctl_binary.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index aea4a9e..b609213 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -3,7 +3,6 @@
 #include "../fs/xfs/xfs_sysctl.h"
 #include <linux/sunrpc/debug.h>
 #include <linux/string.h>
-#include <net/ip_vs.h>
 #include <linux/syscalls.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
-- 
1.7.10.4
