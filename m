From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 1/3 v5] net: ether: Add support for multiplexing and aggregation type
Date: Wed, 16 Aug 2017 18:55:05 -0600
Message-ID: <1502931307-517-2-git-send-email-subashab@codeaurora.org>
References: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44494 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751979AbdHQAz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:55:56 -0400
In-Reply-To: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the multiplexing and aggregation (MAP) ether type 0xDA1A. This
is needed for receiving data in the MAP protocol like RMNET. This is
not an officially registered ID.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/uapi/linux/if_ether.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd..e80b03f 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -104,7 +104,9 @@
 #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
-
+#define ETH_P_MAP       0xDA1A          /* Multiplexing and Aggregation Protocol
+					 *  NOT AN OFFICIALLY REGISTERED ID ]
+					 */
 #define ETH_P_802_3_MIN	0x0600		/* If the value in the ethernet type is less than this value
 					 * then the frame is Ethernet II. Else it is 802.3 */
 
-- 
1.9.1
