From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [net-next v2 1/3] if_ether.h: add IEEE 802.21 Ethertype
Date: Mon, 17 Feb 2014 17:56:11 +0100
Message-ID: <1392656174-14791-2-git-send-email-sw@simonwunderlich.de>
References: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org,
	Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392656174-14791-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the Ethertype for IEEE Std 802.21 - Media Independent Handover
Protocol. This Ethertype is used for network control messages.

Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org>
---
 include/uapi/linux/if_ether.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 2ce0f6a..2e27208 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
