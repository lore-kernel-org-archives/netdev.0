From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/17] net: xfrm: kill XFRM_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:31 -0700
Message-ID: <1461800683-25034-6-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34804 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbcD0XpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:04 -0400
Received: by mail-pa0-f43.google.com with SMTP id r5so25336007pag.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:04 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used anymore.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/xfrm.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index dab9e1b82963..adfebd6f243c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -45,10 +45,8 @@
 
 #ifdef CONFIG_XFRM_STATISTICS
 #define XFRM_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.xfrm_statistics, field)
-#define XFRM_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.xfrm_statistics, field)
 #else
 #define XFRM_INC_STATS(net, field)	((void)(net))
-#define XFRM_INC_STATS_BH(net, field)	((void)(net))
 #endif
 
 
-- 
2.8.0.rc3.226.g39d4020
