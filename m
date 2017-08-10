From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH 2/3] net: Export tcpv6_prot
Date: Thu, 10 Aug 2017 13:33:15 +0300
Message-ID: <1502361196-127278-3-git-send-email-ilyal@mellanox.com>
References: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, aviadye@mellanox.com,
        Boris Pismenny <borisp@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33028 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752162AbdHJKdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 06:33:31 -0400
In-Reply-To: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Boris Pismenny <borisp@mellanox.com>

Want to be able to use these in TLS.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
---
 net/ipv6/tcp_ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2521690..e3a44a5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1944,6 +1944,7 @@ struct proto tcpv6_prot = {
 #endif
 	.diag_destroy		= tcp_abort,
 };
+EXPORT_SYMBOL(tcpv6_prot);
 
 static struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
-- 
1.8.3.1
