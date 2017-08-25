From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 1/3 v9] net: ether: Add support for multiplexing and aggregation type
Date: Thu, 24 Aug 2017 22:39:24 -0600
Message-ID: <1503635966-14076-2-git-send-email-subashab@codeaurora.org>
References: <1503635966-14076-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60084 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbdHYEjw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:39:52 -0400
In-Reply-To: <1503635966-14076-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the multiplexing and aggregation (MAP) ether type 0x00F9. This
is needed for receiving data in the MAP protocol like RMNET. This is
not an officially registered ID.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/uapi/linux/if_ether.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd..0d73ecc 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -137,6 +137,7 @@
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
 #define ETH_P_XDSA	0x00F8		/* Multiplexed DSA protocol	*/
+#define ETH_P_MAP	0x00F9		/* Multiplex & aggregation proto*/
 
 /*
  *	This is an Ethernet frame header.
-- 
1.9.1
