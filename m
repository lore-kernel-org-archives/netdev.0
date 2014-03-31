From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 1/5] netfilter: Fix format string mismatch in ip_vs_proto_name()
Date: Tue,  1 Apr 2014 00:40:15 +0900
Message-ID: <1396280415-31007-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au,
	ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:50026 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbaCaPk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 11:40:27 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so8437154pab.27
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 08:40:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix string mismatch in ip_vs_proto_name()

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f26ee4..d9da8c4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -97,7 +97,7 @@ const char *ip_vs_proto_name(unsigned int proto)
 		return "ICMPv6";
 #endif
 	default:
-		sprintf(buf, "IP_%d", proto);
+		sprintf(buf, "IP_%u", proto);
 		return buf;
 	}
 }
-- 
1.9.1.352.gd393d14
