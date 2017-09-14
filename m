From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] tls: make tls_sw_free_resources static
Date: Thu, 14 Sep 2017 13:22:25 +0200
Message-ID: <20170914112225.4296-1-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:35514 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751413AbdINL1g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 07:27:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the needlessly global function tls_sw_free_resources static to fix
a gcc/sparse warning.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/tls/tls_sw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tls/tls_sw.c b/net/tls/tls_sw.c
index fa596fa71ba7..7d80040a37b6 100644
--- a/net/tls/tls_sw.c
+++ b/net/tls/tls_sw.c
@@ -639,7 +639,7 @@ int tls_sw_sendpage(struct sock *sk, struct page *page,
 	return ret;
 }
 
-void tls_sw_free_resources(struct sock *sk)
+static void tls_sw_free_resources(struct sock *sk)
 {
 	struct tls_context *tls_ctx = tls_get_ctx(sk);
 	struct tls_sw_context *ctx = tls_sw_ctx(tls_ctx);
-- 
2.13.0
