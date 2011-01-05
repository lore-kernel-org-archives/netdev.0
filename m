From: "Henry Ptasinski" <henryp@broadcom.com>
Subject: [PATCH] include/linux/if_ether.h: Add #define ETH_P_LINK_CTL
 for HPNA and wlan local tunnel
Date: Tue, 4 Jan 2011 18:07:14 -0800
Message-ID: <1294193234-804-1-git-send-email-henryp@broadcom.com>
References: <1292298831.26970.263.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: henryp@broadcom.com, brudley@broadcom.com, arend@broadcom.com,
	rvossen@broadcom.com, dowan@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net, joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3117 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab1AECHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 21:07:36 -0500
In-Reply-To: <1292298831.26970.263.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethertype used by HPNA control protocols (LARQ, rate, link, etc) and by
Broadcom wlan drivers for local signalling.

Signed-off-by: Henry Ptasinski <henryp@broadcom.com>
---
 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index f9c3df0..be69043 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -72,6 +72,7 @@
 #define ETH_P_MPLS_UC	0x8847		/* MPLS Unicast traffic		*/
 #define ETH_P_MPLS_MC	0x8848		/* MPLS Multicast traffic	*/
 #define ETH_P_ATMMPOA	0x884c		/* MultiProtocol Over ATM	*/
+#define ETH_P_LINK_CTL	0x886c		/* HPNA, wlan link local tunnel */
 #define ETH_P_ATMFATE	0x8884		/* Frame-based ATM Transport
 					 * over Ethernet
 					 */
-- 
1.7.1


