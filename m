From: sfeldma@gmail.com
Subject: [PATCH net-next 4/7] bridge: define some min/max ageing time constants we'll use next
Date: Fri, 18 Sep 2015 12:55:48 -0700
Message-ID: <1442606151-50429-5-git-send-email-sfeldma@gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36618 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbIRTxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:53:11 -0400
Received: by padhk3 with SMTP id hk3so58889400pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 12:53:10 -0700 (PDT)
In-Reply-To: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/if_bridge.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index dad8b00..6cc6dbc 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -46,6 +46,10 @@ struct br_ip_list {
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
 
+/* values as per ieee8021QBridgeFdbAgingTime */
+#define BR_MIN_AGEING_TIME	(10 * HZ)
+#define BR_MAX_AGEING_TIME	(1000000 * HZ)
+
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
 typedef int br_should_route_hook_t(struct sk_buff *skb);
-- 
1.7.10.4
