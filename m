From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [net-next v4 1/3] if_ether.h: add IEEE 802.21 Ethertype
Date: Mon,  3 Mar 2014 17:23:10 +0100
Message-ID: <1393863792-18172-2-git-send-email-sw@simonwunderlich.de>
References: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de,
	Simon Wunderlich <sw@simonwunderlich.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55036 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbaCCQXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 11:23:17 -0500
In-Reply-To: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the Ethertype for IEEE Std 802.21 - Media Independent Handover
Protocol. This Ethertype is used for network control messages.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
---
 include/uapi/linux/if_ether.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index ba8b15f..750ba67 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -89,6 +89,7 @@
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
+#define ETH_P_80221	0x8917		/* IEEE 802.21 Media Independent Handover Protocol */
 #define ETH_P_QINQ1	0x9100		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
-- 
1.7.10.4
