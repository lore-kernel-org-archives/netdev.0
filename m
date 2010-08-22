From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: use __be16 instead of u16 for the userspace code
Date: Sun, 22 Aug 2010 19:09:33 +0800
Message-ID: <1282475373-24660-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:56215 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083Ab0HVLJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 07:09:57 -0400
Received: by pzk26 with SMTP id 26so1922872pzk.19
        for <netdev@vger.kernel.org>; Sun, 22 Aug 2010 04:09:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/if_pppox.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 1525b21..770e8fa 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -50,8 +50,8 @@ struct pppoe_addr {
  * PPTP addressing definition
  */
 struct pptp_addr {
-	u16             call_id;
-	struct in_addr  sin_addr;
+	__be16		call_id;
+	struct in_addr	sin_addr;
 };
 
 /************************************************************************
