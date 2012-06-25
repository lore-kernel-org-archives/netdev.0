From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 1/8] if_ether.h: Add LLDP ethertype
Date: Mon, 25 Jun 2012 20:28:13 +0200
Message-ID: <1340648900-6547-2-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f51.google.com ([209.85.213.51]:42938 "EHLO
	mail-yw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755718Ab2FYS2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:34 -0400
Received: by yhnn12 with SMTP id n12so3670590yhn.10
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:33 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LLDP ethertype is defined in IEEE Std 802.1ab (2005), clause 8.3.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 include/linux/if_ether.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 56d907a..a5f0612 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -81,6 +81,7 @@
 #define ETH_P_8021AD	0x88A8          /* 802.1ad Service VLAN		*/
 #define ETH_P_802_EX1	0x88B5		/* 802.1 Local Experimental 1.  */
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_LLDP	0x88CC		/* 802.1ab Link Layer Discovery	*/
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
-- 
1.7.10
