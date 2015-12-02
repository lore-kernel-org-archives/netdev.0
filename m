From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/28] net: add netif_is_team_port helper
Date: Wed,  2 Dec 2015 21:07:28 +0100
Message-ID: <1449086871-19911-6-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33347 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbLBUIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:01 -0500
Received: by wmec201 with SMTP id c201so270748359wme.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:00 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to other helpers, caller can use this to find out if device is
team port.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cfb56e0..e7eca8f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3895,6 +3895,11 @@ static inline bool netif_is_team_master(struct net_device *dev)
 	return dev->priv_flags & IFF_TEAM;
 }
 
+static inline bool netif_is_team_port(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_TEAM_PORT;
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
-- 
1.9.3
