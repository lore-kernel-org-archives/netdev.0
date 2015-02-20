From: sfeldma@gmail.com
Subject: [PATCH net-next RFC 2/5] switchdev: add ntf_flags to FDB notifier
Date: Thu, 19 Feb 2015 23:09:52 -0800
Message-ID: <1424416195-19098-3-git-send-email-sfeldma@gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:42553 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbBTHJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:09:30 -0500
Received: by pdbfp1 with SMTP id fp1so5669608pdb.9
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:09:29 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Let switchdev driver set NTF_* flags per FDB entry.  Driver can set NTF_EXT_AGED
to indicate driver/device will aged out entry.  Driver can set NTF_EXT_LEARNED
to indicate driver/device learned this entry.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index cfcdac2..a523745 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -26,6 +26,7 @@ struct netdev_switch_notifier_fdb_info {
 	struct netdev_switch_notifier_info info; /* must be first */
 	const unsigned char *addr;
 	u16 vid;
+	u8 ntf_flags;
 };
 
 static inline struct net_device *
-- 
1.7.10.4
