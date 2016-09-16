From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 13/14] tcp: increase ICSK_CA_PRIV_SIZE from 64 bytes to 88
Date: Fri, 16 Sep 2016 14:49:02 -0400
Message-ID: <1474051743-13311-14-git-send-email-ncardwell@google.com>
References: <1474051743-13311-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:32819 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934583AbcIPSuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 14:50:09 -0400
Received: by mail-qk0-f176.google.com with SMTP id w204so95965775qka.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 11:50:09 -0700 (PDT)
In-Reply-To: <1474051743-13311-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP CUBIC module already uses 64 bytes.
The upcoming TCP BBR module uses 88 bytes.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/inet_connection_sock.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 49dcad4..197a30d 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -134,8 +134,8 @@ struct inet_connection_sock {
 	} icsk_mtup;
 	u32			  icsk_user_timeout;
 
-	u64			  icsk_ca_priv[64 / sizeof(u64)];
-#define ICSK_CA_PRIV_SIZE      (8 * sizeof(u64))
+	u64			  icsk_ca_priv[88 / sizeof(u64)];
+#define ICSK_CA_PRIV_SIZE      (11 * sizeof(u64))
 };
 
 #define ICSK_TIME_RETRANS	1	/* Retransmit timer */
-- 
2.8.0.rc3.226.g39d4020
