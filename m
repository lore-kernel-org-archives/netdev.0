From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 6/9] bonding: remove various function declarations
Date: Wed, 17 Dec 2008 22:28:33 +0100
Message-ID: <20081217213013.897033110@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:50097 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbYLQVaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:19 -0500
Content-Disposition: inline; filename=bonding-3ad-remove-unnecessary-declarations.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are all defined before used, it's therefore ok to remove
them.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -95,34 +95,6 @@ static struct mac_addr null_mac_addr = {
 static u16 ad_ticks_per_sec;
 static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
 
-// ================= 3AD api to bonding and kernel code ==================
-static u16 __get_link_speed(struct port *port);
-static u8 __get_duplex(struct port *port);
-static inline void __initialize_port_locks(struct port *port);
-//conversions
-static u16 __ad_timer_to_ticks(u16 timer_type, u16 Par);
-
-
-// ================= ad code helper functions ==================
-//needed by ad_rx_machine(...)
-static void __record_pdu(struct lacpdu *lacpdu, struct port *port);
-static void __record_default(struct port *port);
-static void __update_selected(struct lacpdu *lacpdu, struct port *port);
-static void __update_default_selected(struct port *port);
-static void __choose_matched(struct lacpdu *lacpdu, struct port *port);
-static void __update_ntt(struct lacpdu *lacpdu, struct port *port);
-
-//needed for ad_mux_machine(..)
-static void __attach_bond_to_agg(struct port *port);
-static void __detach_bond_from_agg(struct port *port);
-static int __agg_ports_are_ready(struct aggregator *aggregator);
-static void __set_agg_ports_ready(struct aggregator *aggregator, int val);
-
-//needed for ad_agg_selection_logic(...)
-static u32 __get_agg_bandwidth(struct aggregator *aggregator);
-static struct aggregator *__get_active_agg(struct aggregator *aggregator);
-
-
 // ================= main 802.3ad protocol functions ==================
 static int ad_lacpdu_send(struct port *port);
 static int ad_marker_send(struct port *port, struct bond_marker *marker);

-- 
