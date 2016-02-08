From: David Miller <davem@davemloft.net>
Subject: [PATCH] tcp: Fix syncookies sysctl default.
Date: Mon, 08 Feb 2016 04:25:43 -0500 (EST)
Message-ID: <20160208.042543.1112131161859466225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kernel@kyup.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcBHJZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 04:25:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Unintentionally the default was changed to zero, fix
that.

Fixes: 12ed8244ed ("ipv4: Namespaceify tcp syncookies sysctl knob")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 11ae706..0d381fa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2389,7 +2389,7 @@ static int __net_init tcp_sk_init(struct net *net)
 
 	net->ipv4.sysctl_tcp_syn_retries = TCP_SYN_RETRIES;
 	net->ipv4.sysctl_tcp_synack_retries = TCP_SYNACK_RETRIES;
-	net->ipv4.sysctl_tcp_syncookies = 0;
+	net->ipv4.sysctl_tcp_syncookies = 1;
 	net->ipv4.sysctl_tcp_reordering = TCP_FASTRETRANS_THRESH;
 	net->ipv4.sysctl_tcp_retries1 = TCP_RETR1;
 	net->ipv4.sysctl_tcp_retries2 = TCP_RETR2;
-- 
2.5.0
