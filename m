From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/26] net: introduce lower state changed info structure for LAG lowers
Date: Tue,  1 Dec 2015 14:48:50 +0100
Message-ID: <1448977744-17930-13-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35324 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbbLANtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:23 -0500
Received: by wmuu63 with SMTP id u63so173631637wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:22 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is shared info structure for bonding and team. Serves to pass down
info about link state and port activity to notification listeners.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 06f17a4..ba2ae91 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2121,6 +2121,11 @@ struct netdev_lag_upper_info {
 	enum netdev_lag_tx_type tx_type;
 };
 
+struct netdev_lag_lower_state_info {
+	u8 link_up : 1,
+	   tx_enabled : 1;
+};
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
-- 
1.9.3
