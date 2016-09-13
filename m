From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/3] net/sched: cls_flower: Specify vlan attributes format in the UAPI header
Date: Tue, 13 Sep 2016 17:02:41 +0300
Message-ID: <1473775361-16547-4-git-send-email-ogerlitz@mellanox.com>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36270 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751567AbcIMOCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:02:55 -0400
In-Reply-To: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Specify the format (size and endianess) for the vlan attributes.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/uapi/linux/pkt_cls.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 60ea2a0..8915b61 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -428,9 +428,9 @@ enum {
 	TCA_FLOWER_KEY_UDP_DST,		/* be16 */
 
 	TCA_FLOWER_FLAGS,
-	TCA_FLOWER_KEY_VLAN_ID,
-	TCA_FLOWER_KEY_VLAN_PRIO,
-	TCA_FLOWER_KEY_VLAN_ETH_TYPE,
+	TCA_FLOWER_KEY_VLAN_ID,		/* be16 */
+	TCA_FLOWER_KEY_VLAN_PRIO,	/* u8   */
+	TCA_FLOWER_KEY_VLAN_ETH_TYPE,	/* be16 */
 
 	TCA_FLOWER_KEY_ENC_KEY_ID,	/* be32 */
 	TCA_FLOWER_KEY_ENC_IPV4_SRC,	/* be32 */
-- 
2.3.7
