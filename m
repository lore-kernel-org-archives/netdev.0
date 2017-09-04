From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH v3 net-next 1/2] net: Export tcpv6_prot
Date: Mon,  4 Sep 2017 13:14:00 +0300
Message-ID: <1504520041-55634-2-git-send-email-ilyal@mellanox.com>
References: <1504520041-55634-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, aviadye@mellanox.com,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37790 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753386AbdIDKOI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 06:14:08 -0400
In-Reply-To: <1504520041-55634-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Want to be able to use these in TLS.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
---
 net/ipv6/tcp_ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 38f76d8..60d0629 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1948,6 +1948,7 @@ struct proto tcpv6_prot = {
 #endif
 	.diag_destroy		= tcp_abort,
 };
+EXPORT_SYMBOL_GPL(tcpv6_prot);
 
 /* thinking of making this const? Don't.
  * early_demux can change based on sysctl.
-- 
1.8.3.1
