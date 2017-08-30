From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 2/3 v11] net: arp: Add support for raw IP device
Date: Tue, 29 Aug 2017 22:44:17 -0600
Message-ID: <1504068258-16982-3-git-send-email-subashab@codeaurora.org>
References: <1504068258-16982-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57070 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdH3Epp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 00:45:45 -0400
In-Reply-To: <1504068258-16982-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the raw IP type. This is needed for raw IP net devices
like rmnet.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/uapi/linux/if_arp.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index cf73510..a2a6356 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -59,6 +59,7 @@
 #define ARPHRD_LAPB	516		/* LAPB				*/
 #define ARPHRD_DDCMP    517		/* Digital's DDCMP protocol     */
 #define ARPHRD_RAWHDLC	518		/* Raw HDLC			*/
+#define ARPHRD_RAWIP    519		/* Raw IP                       */
 
 #define ARPHRD_TUNNEL	768		/* IPIP tunnel			*/
 #define ARPHRD_TUNNEL6	769		/* IP6IP6 tunnel       		*/
-- 
1.9.1
