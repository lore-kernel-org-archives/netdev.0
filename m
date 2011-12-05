From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH] netback: Fix alert message.
Date: Mon, 5 Dec 2011 16:57:44 +0000
Message-ID: <1323104264-3601-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, Wei Liu <wei.liu2@citrix.com>
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:40168 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756338Ab1LEQ5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 11:57:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original message in netback_init was 'kthread_run() fails', which should be
'kthread_create() fails'.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 1ae270e..15e332d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1668,7 +1668,7 @@ static int __init netback_init(void)
 					     "netback/%u", group);
 
 		if (IS_ERR(netbk->task)) {
-			printk(KERN_ALERT "kthread_run() fails at netback\n");
+			printk(KERN_ALERT "kthread_create() fails at netback\n");
 			del_timer(&netbk->net_timer);
 			rc = PTR_ERR(netbk->task);
 			goto failed_init;
-- 
1.7.2.5
