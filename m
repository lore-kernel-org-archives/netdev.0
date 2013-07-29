From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] flow_dissector: Add support for IPPROTO_IPV6
Date: Mon, 29 Jul 2013 10:50:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1307291048420.10983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:41040 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757381Ab3G2Ru6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 13:50:58 -0400
Received: by mail-ve0-f201.google.com with SMTP id m1so342757ves.2
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 10:50:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support IPPROTO_IPV6 similar to IPPROTO_IPIP

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 3259446..9b96ba5 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -141,6 +141,9 @@ ipv6:
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
 		goto ip;
+	case IPPROTO_IPV6:
+		proto = htons(ETH_P_IPV6);
+		goto ip;
 	default:
 		break;
 	}
-- 
1.8.3
