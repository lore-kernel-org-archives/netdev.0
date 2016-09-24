From: sthemmin@exchange.microsoft.com
Subject: [PATCH] hv_netvsc: fix comments
Date: Fri, 23 Sep 2016 17:08:17 -0700
Message-ID: <1474675697-22805-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:35682
        "EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759852AbcIWWRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 18:17:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Typo's and spelling errors. Also remove old comment from staging era.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 284b97b..d7c1cc6 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -433,7 +433,7 @@ struct nvsp_1_message_revoke_send_buffer {
  */
 struct nvsp_1_message_send_rndis_packet {
 	/*
-	 * This field is specified by RNIDS. They assume there's two different
+	 * This field is specified by RNDIS. They assume there's two different
 	 * channels of communication. However, the Network VSP only has one.
 	 * Therefore, the channel travels with the RNDIS packet.
 	 */
@@ -578,7 +578,7 @@ struct nvsp_5_send_indirect_table {
 	/* The number of entries in the send indirection table */
 	u32 count;
 
-	/* The offset of the send indireciton table from top of this struct.
+	/* The offset of the send indirection table from top of this struct.
 	 * The send indirection table tells which channel to put the send
 	 * traffic on. Each entry is a channel number.
 	 */
@@ -733,7 +733,6 @@ struct netvsc_device {
 	struct nvsp_message channel_init_pkt;
 
 	struct nvsp_message revoke_packet;
-	/* unsigned char HwMacAddr[HW_MACADDR_LEN]; */
 
 	struct vmbus_channel *chn_table[VRSS_CHANNEL_MAX];
 	u32 send_table[VRSS_SEND_TAB_SIZE];
@@ -1238,7 +1237,7 @@ struct rndis_message {
 	u32 ndis_msg_type;
 
 	/* Total length of this message, from the beginning */
-	/* of the sruct rndis_message, in bytes. */
+	/* of the struct rndis_message, in bytes. */
 	u32 msg_len;
 
 	/* Actual message */
-- 
1.7.4.1
