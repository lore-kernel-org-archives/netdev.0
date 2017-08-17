From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 2/3 v5] net: arp: Add support for raw IP device
Date: Wed, 16 Aug 2017 18:55:06 -0600
Message-ID: <1502931307-517-3-git-send-email-subashab@codeaurora.org>
References: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44730 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751979AbdHQAz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:55:59 -0400
In-Reply-To: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
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
