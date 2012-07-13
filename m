From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 1/2] be2net: Add description about various RSS hash types
Date: Fri, 13 Jul 2012 18:15:51 +0530
Message-ID: <ecab14f7-24e9-4329-9d62-640086a29b52@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:18977 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933050Ab2GMMqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 08:46:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incorporated review comment from Eric Dumazet. Added description
about different RSS hash types which adapter is capable of.
Will add support for ETHTOOL_GRXFH and ETHTOOL_SRXFX as suggested
by Ben Hutchings in a later patch.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 45d70de..d5a4ded 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1082,8 +1082,18 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 function_caps;
 };
 
-/******************** RSS Config *******************/
-/* RSS types */
+/******************** RSS Config ****************************************/
+/* RSS type		Input parameters used to compute RX hash
+ * RSS_ENABLE_IPV4	SRC IPv4, DST IPv4
+ * RSS_ENABLE_TCP_IPV4	SRC IPv4, DST IPv4, TCP SRC PORT, TCP DST PORT
+ * RSS_ENABLE_IPV6	SRC IPv6, DST IPv6
+ * RSS_ENABLE_TCP_IPV6	SRC IPv6, DST IPv6, TCP SRC PORT, TCP DST PORT
+ * RSS_ENABLE_UDP_IPV4	SRC IPv4, DST IPv4, UDP SRC PORT, UDP DST PORT
+ * RSS_ENABLE_UDP_IPV6	SRC IPv6, DST IPv6, UDP SRC PORT, UDP DST PORT
+ *
+ * When multiple RSS types are enabled, HW picks the best hash policy
+ * based on the type of the received packet.
+ */
 #define RSS_ENABLE_NONE				0x0
 #define RSS_ENABLE_IPV4				0x1
 #define RSS_ENABLE_TCP_IPV4			0x2
-- 
1.6.0.2
