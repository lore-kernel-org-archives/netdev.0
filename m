From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] bridge: use __u16 in if_bridge.h
Date: Thu, 14 Feb 2013 13:32:31 +0800
Message-ID: <1360819951-19484-1-git-send-email-amwang@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39550 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126Ab3BNFcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 00:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

We should use "__u16" instead of "u16" in the user-space visable
header.

Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index f1bf8d3..2d70d79 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -124,8 +124,8 @@ enum {
 #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
 
 struct bridge_vlan_info {
-	u16 flags;
-	u16 vid;
+	__u16 flags;
+	__u16 vid;
 };
 
 /* Bridge multicast database attributes
