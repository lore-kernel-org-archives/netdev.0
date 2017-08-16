From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 2/3 v4] net: arp: Add support for raw IP device
Date: Tue, 15 Aug 2017 22:15:52 -0600
Message-ID: <1502856953-30321-3-git-send-email-subashab@codeaurora.org>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57708 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdHPEQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 00:16:35 -0400
In-Reply-To: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the raw IP type. This is needed for raw IP net devices
like rmnet.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/uapi/linux/if_arp.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index cf73510..d6650e2 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -59,6 +59,7 @@
 #define ARPHRD_LAPB	516		/* LAPB				*/
 #define ARPHRD_DDCMP    517		/* Digital's DDCMP protocol     */
 #define ARPHRD_RAWHDLC	518		/* Raw HDLC			*/
+#define ARPHRD_RAWIP    530             /* Raw IP                       */
 
 #define ARPHRD_TUNNEL	768		/* IPIP tunnel			*/
 #define ARPHRD_TUNNEL6	769		/* IP6IP6 tunnel       		*/
-- 
1.9.1
