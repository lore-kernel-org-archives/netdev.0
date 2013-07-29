From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 2/2] flow_dissector: add support for IPPROTO_IPV6
Date: Mon, 29 Jul 2013 11:07:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1307291104270.10729@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:52976 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616Ab3G2SHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 14:07:44 -0400
Received: by mail-qa0-f74.google.com with SMTP id hu14so299412qab.3
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 11:07:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support IPPROTO_IPV6 similar to IPPROTO_IPIP

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 3259446..ade9ff1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -141,6 +141,9 @@ ipv6:
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
 		goto ip;
+	case IPPROTO_IPV6:
+		proto = htons(ETH_P_IPV6);
+		goto ipv6;
 	default:
 		break;
 	}
-- 
1.8.3
