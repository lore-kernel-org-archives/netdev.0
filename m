From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] if_ether.h: Add #define ETH_P_LARQ for
 HPNA/LARQ
Date: Mon, 13 Dec 2010 16:47:47 -0800
Message-ID: <1292287667.26970.114.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Dowan Kim <dowan@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2597 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758098Ab0LNArt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 19:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LARQ seems to be used by Broadcom's staging driver.
Might as well add a #define for it to the normal location.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/if_ether.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index f9c3df0..b257e99 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -71,6 +71,8 @@
 #define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
 #define ETH_P_MPLS_UC	0x8847		/* MPLS Unicast traffic		*/
 #define ETH_P_MPLS_MC	0x8848		/* MPLS Multicast traffic	*/
+#define ETH_P_LARQ	0x886c		/* HPNA / Broadcom
+					 * Limited Automatic Repeat reQuest */
 #define ETH_P_ATMMPOA	0x884c		/* MultiProtocol Over ATM	*/
 #define ETH_P_ATMFATE	0x8884		/* Frame-based ATM Transport
 					 * over Ethernet


