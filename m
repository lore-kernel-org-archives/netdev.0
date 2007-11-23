From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 2/8] ipg: remove boolean macros
Date: Fri, 23 Nov 2007 10:18:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231018040.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbXKWISY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:18:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.h |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -478,38 +478,34 @@ enum ipg_regs {
  *	Tune
  */
 
-/* Miscellaneous Constants. */
-#define   TRUE  1
-#define   FALSE 0
-
 /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS append on TX. */
-#define         IPG_APPEND_FCS_ON_TX         TRUE
+#define         IPG_APPEND_FCS_ON_TX         1
 
 /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS strip on RX. */
-#define         IPG_STRIP_FCS_ON_RX          TRUE
+#define         IPG_STRIP_FCS_ON_RX          1
 
 /* Assign IPG_DROP_ON_RX_ETH_ERRORS > 0 to drop RX frames with
  * Ethernet errors.
  */
-#define         IPG_DROP_ON_RX_ETH_ERRORS    TRUE
+#define         IPG_DROP_ON_RX_ETH_ERRORS    1
 
 /* Assign IPG_INSERT_MANUAL_VLAN_TAG > 0 to insert VLAN tags manually
  * (via TFC).
  */
-#define		IPG_INSERT_MANUAL_VLAN_TAG   FALSE
+#define		IPG_INSERT_MANUAL_VLAN_TAG   0
 
 /* Assign IPG_ADD_IPCHECKSUM_ON_TX > 0 for auto IP checksum on TX. */
-#define         IPG_ADD_IPCHECKSUM_ON_TX     FALSE
+#define         IPG_ADD_IPCHECKSUM_ON_TX     0
 
 /* Assign IPG_ADD_TCPCHECKSUM_ON_TX > 0 for auto TCP checksum on TX.
  * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
  */
-#define         IPG_ADD_TCPCHECKSUM_ON_TX    FALSE
+#define         IPG_ADD_TCPCHECKSUM_ON_TX    0
 
 /* Assign IPG_ADD_UDPCHECKSUM_ON_TX > 0 for auto UDP checksum on TX.
  * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
  */
-#define         IPG_ADD_UDPCHECKSUM_ON_TX    FALSE
+#define         IPG_ADD_UDPCHECKSUM_ON_TX    0
 
 /* If inserting VLAN tags manually, assign the IPG_MANUAL_VLAN_xx
  * constants as desired.
