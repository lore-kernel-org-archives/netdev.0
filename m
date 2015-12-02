From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 14/28] net: introduce lower state changed info structure for LAG lowers
Date: Wed,  2 Dec 2015 21:07:37 +0100
Message-ID: <1449086871-19911-15-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34160 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733AbbLBUIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:13 -0500
Received: by wmvv187 with SMTP id v187so272524161wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:12 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
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
index a392d0f..e7e2d6d 100644
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
