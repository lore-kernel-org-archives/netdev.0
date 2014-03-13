From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/2] ether: add loopback type ETH_P_LOOPBACK
Date: Thu, 13 Mar 2014 12:41:57 +0100
Message-ID: <1394710918-29540-2-git-send-email-vfalico@redhat.com>
References: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Neil Jerram <Neil.Jerram@metaswitch.com>,
	Simon Horman <horms@verge.net.au>,
	Arvid Brodin <Arvid.Brodin@xdin.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753473AbaCMLqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 07:46:31 -0400
In-Reply-To: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per IEEE 802.3*, the correct packet type for loopback 0x9000. There's
already one ETH_P_LOOP 0x0060, which has been there for ages, however it's
plainly wrong as anything that small is considered a length field.

We can't remove it because legacy, so add a new type which corresponds to
the correct id.

http://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml

CC: "David S. Miller" <davem@davemloft.net>
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
CC: Simon Wunderlich <sw@simonwunderlich.de>
CC: Neil Jerram <Neil.Jerram@metaswitch.com>
CC: Simon Horman <horms@verge.net.au>
CC: Arvid Brodin <Arvid.Brodin@xdin.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/uapi/linux/if_ether.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 750ba67..0f8210b 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -90,6 +90,7 @@
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
 #define ETH_P_80221	0x8917		/* IEEE 802.21 Media Independent Handover Protocol */
+#define ETH_P_LOOPBACK	0x9000		/* Ethernet loopback packet, per IEEE 802.3 */
 #define ETH_P_QINQ1	0x9100		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ2	0x9200		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
-- 
1.8.4
