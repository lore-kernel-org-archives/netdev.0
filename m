From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [PATCH] drivers/net/ipg: Remove local definition of TRUE/FALSE
Date: Mon, 10 Dec 2007 20:29:59 +0100 (MET)
Message-ID: <20071210193139.16433.95480.sendpatchset@thinktank.campus.ltu.se>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Knutsson <ricknu-0@student.ltu.se>
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756797AbXLJTbK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove local definition of TRUE/FALSE.

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
---


diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index d5d092c..4484778 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -490,38 +490,34 @@ enum ipg_regs {
  *	Tune
  */
 
-/* Miscellaneous Constants. */
-#define   TRUE  1
-#define   FALSE 0
-
 /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS append on TX. */
-#define         IPG_APPEND_FCS_ON_TX         TRUE
+#define         IPG_APPEND_FCS_ON_TX         true
 
 /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS strip on RX. */
-#define         IPG_STRIP_FCS_ON_RX          TRUE
+#define         IPG_STRIP_FCS_ON_RX          true
 
 /* Assign IPG_DROP_ON_RX_ETH_ERRORS > 0 to drop RX frames with
  * Ethernet errors.
  */
-#define         IPG_DROP_ON_RX_ETH_ERRORS    TRUE
+#define         IPG_DROP_ON_RX_ETH_ERRORS    true
 
 /* Assign IPG_INSERT_MANUAL_VLAN_TAG > 0 to insert VLAN tags manually
  * (via TFC).
  */
-#define		IPG_INSERT_MANUAL_VLAN_TAG   FALSE
+#define		IPG_INSERT_MANUAL_VLAN_TAG   false
 
 /* Assign IPG_ADD_IPCHECKSUM_ON_TX > 0 for auto IP checksum on TX. */
-#define         IPG_ADD_IPCHECKSUM_ON_TX     FALSE
+#define         IPG_ADD_IPCHECKSUM_ON_TX     false
 
 /* Assign IPG_ADD_TCPCHECKSUM_ON_TX > 0 for auto TCP checksum on TX.
  * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
  */
-#define         IPG_ADD_TCPCHECKSUM_ON_TX    FALSE
+#define         IPG_ADD_TCPCHECKSUM_ON_TX    false
 
 /* Assign IPG_ADD_UDPCHECKSUM_ON_TX > 0 for auto UDP checksum on TX.
  * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
  */
-#define         IPG_ADD_UDPCHECKSUM_ON_TX    FALSE
+#define         IPG_ADD_UDPCHECKSUM_ON_TX    false
 
 /* If inserting VLAN tags manually, assign the IPG_MANUAL_VLAN_xx
  * constants as desired.
