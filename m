From: Peter Heise <mail@pheise.de>
Subject: [PATCH net-next] net/hsr: Fixed version field in ENUM
Date: Wed, 20 Apr 2016 09:08:29 +0200
Message-ID: <20160420070829.GA24563@aircraft-controller>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.heise@airbus.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pheise.de ([81.88.24.24]:54792 "EHLO ghost.pheise.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932248AbcDTHIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 03:08:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New field (IFLA_HSR_VERSION) was added in the middle of an existing
ENUM and would break kernel ABI, therefore moved to the end.
Reported by Stephen Hemminger.

Signed-off-by: Peter Heise <peter.heise@airbus.com>
---
 include/uapi/linux/if_link.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5ffdcb3..af8fd58 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -774,9 +774,9 @@ enum {
 	IFLA_HSR_SLAVE1,
 	IFLA_HSR_SLAVE2,
 	IFLA_HSR_MULTICAST_SPEC,	/* Last byte of supervision addr */
-	IFLA_HSR_VERSION,		/* HSR version */
 	IFLA_HSR_SUPERVISION_ADDR,	/* Supervision frame multicast addr */
 	IFLA_HSR_SEQ_NR,
+	IFLA_HSR_VERSION,		/* HSR version */
 	__IFLA_HSR_MAX,
 };
 
-- 
2.5.0
