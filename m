From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 02/16] sfc: change definition of MC_CMD_VADAPTOR_ALLOC
Date: Wed, 20 May 2015 11:08:40 +0100
Message-ID: <555C5D28.7010504@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:31917 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753291AbbETKIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:08:47 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 797b9df..fc50be7 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -5877,7 +5877,7 @@
 #define MC_CMD_0x98_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VADAPTOR_ALLOC_IN msgrequest */
-#define    MC_CMD_VADAPTOR_ALLOC_IN_LEN 16
+#define    MC_CMD_VADAPTOR_ALLOC_IN_LEN 30
 /* The port to connect to the v-adaptor's port. */
 #define       MC_CMD_VADAPTOR_ALLOC_IN_UPSTREAM_PORT_ID_OFST 0
 /* Flags controlling v-adaptor creation */
@@ -5886,6 +5886,19 @@
 #define        MC_CMD_VADAPTOR_ALLOC_IN_FLAG_AUTO_VADAPTOR_WIDTH 1
 /* The number of VLAN tags to strip on receive */
 #define       MC_CMD_VADAPTOR_ALLOC_IN_NUM_VLANS_OFST 12
+/* The number of VLAN tags to transparently insert/remove. */
+#define       MC_CMD_VADAPTOR_ALLOC_IN_NUM_VLAN_TAGS_OFST 16
+/* The actual VLAN tags to insert/remove */
+#define       MC_CMD_VADAPTOR_ALLOC_IN_VLAN_TAGS_OFST 20
+#define        MC_CMD_VADAPTOR_ALLOC_IN_VLAN_TAG_0_LBN 0
+#define        MC_CMD_VADAPTOR_ALLOC_IN_VLAN_TAG_0_WIDTH 16
+#define        MC_CMD_VADAPTOR_ALLOC_IN_VLAN_TAG_1_LBN 16
+#define        MC_CMD_VADAPTOR_ALLOC_IN_VLAN_TAG_1_WIDTH 16
+/* The MAC address to assign to this v-adaptor */
+#define       MC_CMD_VADAPTOR_ALLOC_IN_MACADDR_OFST 24
+#define       MC_CMD_VADAPTOR_ALLOC_IN_MACADDR_LEN 6
+/* enum: Derive the MAC address from the upstream port */
+#define          MC_CMD_VADAPTOR_ALLOC_IN_AUTO_MAC  0x0
 
 /* MC_CMD_VADAPTOR_ALLOC_OUT msgresponse */
 #define    MC_CMD_VADAPTOR_ALLOC_OUT_LEN 0
