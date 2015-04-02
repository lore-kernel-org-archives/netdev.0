From: sfeldma@gmail.com
Subject: [PATCH net-next v3 04/26] switchdev: add bridge port flags attr
Date: Thu,  2 Apr 2015 01:09:50 -0700
Message-ID: <1427962212-18411-5-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35335 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbbDBIJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:26 -0400
Received: by pddn5 with SMTP id n5so82111198pdd.2
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:25 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9fe3b1c..14baa66 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -22,6 +22,7 @@ enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
 	SWDEV_ATTR_PORT_PARENT_ID,
 	SWDEV_ATTR_PORT_STP_STATE,
+	SWDEV_ATTR_PORT_BRIDGE_FLAGS,
 };
 
 struct swdev_attr {
@@ -31,6 +32,7 @@ struct swdev_attr {
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
+		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 	};
 };
 
-- 
1.7.10.4
