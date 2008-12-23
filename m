From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 04/10] 802.3ad: remove typedef around ad_system
Date: Tue, 23 Dec 2008 23:01:05 +0100
Message-ID: <20081223220554.978496107@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	Holger Eitzenberger <heitzenberger@astaro.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:58215 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbYLWWGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:03 -0500
Content-Disposition: inline; filename=bonding-3ad-remove-unused-typedef.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As typedefs are considered a bad thing most of the time remove the
typedef around ad_system.

Signed-off-by: Holger Eitzenberger <heitzenberger@astaro.com>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -244,10 +244,10 @@ typedef struct port {
 } port_t;
 
 // system structure
-typedef struct ad_system {
+struct ad_system {
 	u16 sys_priority;
 	struct mac_addr sys_mac_addr;
-} ad_system_t;
+};
 
 #ifdef __ia64__
 #pragma pack()
@@ -258,7 +258,7 @@ typedef struct ad_system {
 #define SLAVE_AD_INFO(slave) ((slave)->ad_info)
 
 struct ad_bond_info {
-	ad_system_t system;	    // 802.3ad system structure
+	struct ad_system system;	    /* 802.3ad system structure */
 	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
 	u32 agg_select_mode;	    // Mode of selection of active aggregator(bandwidth/count)
 	int lacp_fast;		/* whether fast periodic tx should be

-- 
