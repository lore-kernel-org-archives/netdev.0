From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 1/5] af_ieee802154: drop IEEE802154_SIOC_ADD_SLAVE declaration
Date: Tue,  4 Aug 2009 02:51:38 +0400
Message-ID: <1249339902-10613-2-git-send-email-dbaryshkov@gmail.com>
References: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:50618 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbZHCWwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 18:52:13 -0400
Received: by fxm17 with SMTP id 17so2939398fxm.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 15:52:13 -0700 (PDT)
In-Reply-To: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
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

