From: Henrik Austad <henrik-RT+80VE2nyv1P9xLtpHBDw@public.gmane.org>
Subject: [PATCH] ether: add IEEE 1722 ethertype - TSN
Date: Wed,  9 Sep 2015 12:25:17 +0200
Message-ID: <1441794317-21503-1-git-send-email-henrik@austad.us>
Cc: Henrik Austad <henrik-RT+80VE2nyv1P9xLtpHBDw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

IEEE 1722 describes AVB (later renamed to TSN - Time Sensitive
Networking), a protocol, encapsualtion and synchronization to utilize
standard networks for audio/video (and later other time-sensitive)
streams.

This standard uses ethertype 0x22F0.

http://standards.ieee.org/develop/regauth/ethertype/eth.txt

This is a respin of a previous patch ("ether: add AVB frame type
ETH_P_AVB")

CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Henrik Austad <henrik-RT+80VE2nyv1P9xLtpHBDw@public.gmane.org>
---
 include/uapi/linux/if_ether.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index aa63ed023c2b..ea9221b0331a 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -42,6 +42,7 @@
 #define ETH_P_LOOP	0x0060		/* Ethernet Loopback packet	*/
 #define ETH_P_PUP	0x0200		/* Xerox PUP packet		*/
 #define ETH_P_PUPAT	0x0201		/* Xerox PUP Addr Trans packet	*/
+#define ETH_P_TSN	0x22F0		/* TSN (IEEE 1722) packet	*/
 #define ETH_P_IP	0x0800		/* Internet Protocol packet	*/
 #define ETH_P_X25	0x0805		/* CCITT X.25			*/
 #define ETH_P_ARP	0x0806		/* Address Resolution packet	*/
-- 
1.9.1
