From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 01/10] af_ieee802154: drop IEEE802154_SIOC_ADD_SLAVE declaration
Date: Fri,  7 Aug 2009 16:58:36 +0400
Message-ID: <1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:35215 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757257AbZHGM7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 08:59:19 -0400
Received: by ewy10 with SMTP id 10so1509848ewy.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 05:59:20 -0700 (PDT)
In-Reply-To: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE802154_SIOC_ADD_SLAVE was used to allocate 802.15.4 interfaces
on the top of radio. It's not used anymore, drop it.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/net/af_ieee802154.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/include/net/af_ieee802154.h b/include/net/af_ieee802154.h
index 0d78605..e9c70ea 100644
--- a/include/net/af_ieee802154.h
+++ b/include/net/af_ieee802154.h
@@ -54,7 +54,4 @@ struct sockaddr_ieee802154 {
 	struct ieee802154_addr addr;
 };
 
-/* master device */
-#define IEEE802154_SIOC_ADD_SLAVE		(SIOCDEVPRIVATE + 0)
-
 #endif
-- 
1.6.3.3

