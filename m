From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: remove obsolete comment in ip6_append_data()
Date: Fri, 25 Jul 2014 14:45:11 +0800
Message-ID: <1406270711-21752-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:44201 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758027AbaGYGpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:45:18 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so5105810pdj.22
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 23:45:17 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id hu11sm10271898pdb.53.2014.07.24.23.45.14
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 23:45:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

After 11878b40e[net-timestamp: SOCK_RAW and PING timestamping], this comment
becomes obsolete since the codes check not only UDP socket, but also RAW sock;
and the codes are clear, not need the comments

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ip6_output.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 759456f..2e339d2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1270,7 +1270,6 @@ emsgsize:
 		}
 	}
 
-	/* For UDP, check if TX timestamp is enabled */
 	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW)
 		sock_tx_timestamp(sk, &tx_flags);
 
-- 
1.7.10.4
