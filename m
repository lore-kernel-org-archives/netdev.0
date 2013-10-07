From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] netfilter: ipvs: ip_vs_sync: Remove unused variable
Date: Mon,  7 Oct 2013 18:09:02 -0300
Message-ID: <1381180142-3388-1-git-send-email-festevam@gmail.com>
Cc: ja@ssi.bg, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:46078 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab3JGVPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 17:15:21 -0400
Received: by mail-yh0-f41.google.com with SMTP id f73so1918496yha.28
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 14:15:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Variable 'ret' is not used anywhere and it causes the following build warning: 

net/netfilter/ipvs/ip_vs_sync.c: In function 'sync_thread_master':
net/netfilter/ipvs/ip_vs_sync.c:1640:8: warning: unused variable 'ret' [-Wunused-variable]

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f63c238..d258125 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
 			continue;
 		}
 		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
-			int ret = __wait_event_interruptible(*sk_sleep(sk),
+			__wait_event_interruptible(*sk_sleep(sk),
 						   sock_writeable(sk) ||
 						   kthread_should_stop());
 			if (unlikely(kthread_should_stop()))
-- 
1.8.1.2
