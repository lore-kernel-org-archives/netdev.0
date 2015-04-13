From: sfeldma@gmail.com
Subject: [PATCH net-next v4 04/24] switchdev: add bridge port flags attr
Date: Sun, 12 Apr 2015 23:16:58 -0700
Message-ID: <1428905838-14920-5-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34744 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014AbbDMGQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:37 -0400
Received: by pacyx8 with SMTP id yx8so91983918pac.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:36 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index fa553ee..512945d 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -27,6 +27,7 @@ enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
 	SWDEV_ATTR_PORT_PARENT_ID,
 	SWDEV_ATTR_PORT_STP_STATE,
+	SWDEV_ATTR_PORT_BRIDGE_FLAGS,
 };
 
 struct swdev_attr {
@@ -36,6 +37,7 @@ struct swdev_attr {
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
+		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 	};
 };
 
-- 
1.7.10.4
