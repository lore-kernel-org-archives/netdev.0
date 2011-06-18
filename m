From: greearb@candelatech.com
Subject: [PATCH v2 2/5] net:  Add pkt-type PACKET_INVALID
Date: Sat, 18 Jun 2011 13:47:22 -0700
Message-ID: <1308430045-24816-3-git-send-email-greearb@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33322 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab1FRUsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:48:07 -0400
In-Reply-To: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This will be used for errored frames received from NICs.
It re-uses the un-used PACKET_FASTROUTE value, but leaves that
define in just in case some user-space app requires it.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 7b31863... 86f06e4... M	include/linux/if_packet.h
 include/linux/if_packet.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 7b31863..86f06e4 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -26,9 +26,12 @@ struct sockaddr_ll {
 #define PACKET_MULTICAST	2		/* To group		*/
 #define PACKET_OTHERHOST	3		/* To someone else 	*/
 #define PACKET_OUTGOING		4		/* Outgoing of any type */
-/* These ones are invisible by user level */
+/* This one is invisible by user level */
 #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
-#define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
+#define PACKET_FASTROUTE	6		/* Fastrouted frame, not used */
+#define PACKET_INVALID		6		/* Packet has errors, perhaps
+						 * received with bad FCS
+						 */
 
 /* Packet socket options */
 
-- 
1.7.3.4

