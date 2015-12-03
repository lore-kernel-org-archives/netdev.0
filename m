From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 14/28] net: introduce lower state changed info structure for LAG lowers
Date: Thu,  3 Dec 2015 12:12:16 +0100
Message-ID: <1449141150-8172-15-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38727 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760091AbbLCLMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:55 -0500
Received: by wmec201 with SMTP id c201so17316669wme.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:53 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
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
