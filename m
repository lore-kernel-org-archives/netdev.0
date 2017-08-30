From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 1/3 v11] net: ether: Add support for multiplexing and aggregation type
Date: Tue, 29 Aug 2017 22:44:16 -0600
Message-ID: <1504068258-16982-2-git-send-email-subashab@codeaurora.org>
References: <1504068258-16982-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56876 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbdH3Epm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 00:45:42 -0400
In-Reply-To: <1504068258-16982-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the Qualcomm multiplexing and aggregation (MAP) ether type 0x00F9.
This is needed for receiving data in the MAP protocol like RMNET. This is
not an officially registered ID.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/uapi/linux/if_ether.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd..30526db 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -137,6 +137,9 @@
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
 #define ETH_P_XDSA	0x00F8		/* Multiplexed DSA protocol	*/
+#define ETH_P_MAP	0x00F9		/* Qualcomm multiplexing and
+					 * aggregation protocol
+					 */
 
 /*
  *	This is an Ethernet frame header.
-- 
1.9.1
