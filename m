From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/3] netvsc: remove unused #define
Date: Thu, 16 Mar 2017 16:12:39 -0700
Message-ID: <20170316231239.12996-4-sthemmin@microsoft.com>
References: <20170316231239.12996-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net, haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35461 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752562AbdCPXXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:23:03 -0400
Received: by mail-pg0-f46.google.com with SMTP id b129so32030714pgc.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:21:37 -0700 (PDT)
In-Reply-To: <20170316231239.12996-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used anywhere.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index b09c4fca1805..6b5f75217694 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -1427,9 +1427,6 @@ struct rndis_message {
 	((void *) rndis_msg)
 
 
-#define __struct_bcount(x)
-
-
 
 #define RNDIS_HEADER_SIZE	(sizeof(struct rndis_message) - \
 				 sizeof(union rndis_message_container))
-- 
2.11.0
