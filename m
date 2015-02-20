From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] [RESEND] ethtool: Add hw-switch-offload to netdev_features_strings.
Date: Fri, 20 Feb 2015 21:34:58 +0200
Message-ID: <1424460898-4045-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:35615 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112AbbBTTf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:35:29 -0500
Received: by wevl61 with SMTP id l61so3308985wev.2
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 11:35:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit aafb3e98b279 (netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature 
flag for switch device offloads) add a new feature without adding it to 
netdev_features_strings array; this patch fixes this.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/core/ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91f74f3..aa378ec 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -98,6 +98,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
+	[NETIF_F_HW_SWITCH_OFFLOAD_BIT] = "hw-switch-offload",
 };
 
 static const char
-- 
2.1.0
