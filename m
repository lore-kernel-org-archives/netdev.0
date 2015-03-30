From: sfeldma@gmail.com
Subject: [PATCH net-next 05/18] switchdev: add bridge port flags attr
Date: Mon, 30 Mar 2015 01:40:23 -0700
Message-ID: <1427704836-8776-6-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35030 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbbC3Ijv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:51 -0400
Received: by patj18 with SMTP id j18so4801865pat.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:50 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 99050b0..2ac5240 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -18,6 +18,7 @@ enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
 	SWDEV_ATTR_PORT_PARENT_ID,
 	SWDEV_ATTR_PORT_STP_STATE,
+	SWDEV_ATTR_PORT_BRIDGE_FLAGS,
 };
 
 #define SWDEV_ATTR_F_NO_RECURSE		BIT(0)
@@ -29,6 +30,7 @@ struct swdev_attr {
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
+		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 	};
 };
 
-- 
1.7.10.4
