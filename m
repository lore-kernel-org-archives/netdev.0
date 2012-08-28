From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] tipc: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 21:05:16 +0800
Message-ID: <CAPgLHd9sEThjDHx5OP4n6ZDNYv9xC_=MCq-VZOhp+Sp3jTeOag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:41398 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616Ab2H1NFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:05:17 -0400
Received: by qcro28 with SMTP id o28so3325858qcr.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 06:05:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/tipc/port.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 07c42fb..9227d2c 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -770,8 +770,7 @@ static void port_dispatcher_sigh(void *dummy)
 				break;
 			}
 		}
-		if (buf)
-			kfree_skb(buf);
+		kfree_skb(buf);
 		buf = next;
 		continue;
 err:
@@ -819,8 +818,7 @@ err:
 				break;
 			}
 		}
-		if (buf)
-			kfree_skb(buf);
+		kfree_skb(buf);
 		buf = next;
 		continue;
 reject:
