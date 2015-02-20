From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ethtool: Add hw-switch-offload to netdev_features_strings.
Date: Sat, 21 Feb 2015 00:50:48 +0200
Message-ID: <1424472648-24828-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30118 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548AbbBTTBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 14:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit aafb3e98b279 (netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
flag for switch device offloads) added a new feature without adding it to
netdev_features_strings array; this patch fixes this.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/core/ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91f74f3..fc5feda 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -98,6 +98,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
+        [NETIF_F_HW_SWITCH_OFFLOAD_BIT] = "hw-switch-offload",
 };
 
 static const char
-- 
1.9.3
