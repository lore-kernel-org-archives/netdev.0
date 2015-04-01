From: sfeldma@gmail.com
Subject: [PATCH net-next v2 04/26] switchdev: add bridge port flags attr
Date: Wed,  1 Apr 2015 03:07:40 -0700
Message-ID: <1427882882-2533-5-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35844 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbbDAKGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:33 -0400
Received: by pdmh5 with SMTP id h5so37925308pdm.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:33 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 86b614c..73fa2a0 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -21,6 +21,7 @@ enum swdev_attr_id {
 	SWDEV_ATTR_UNDEFINED,
 	SWDEV_ATTR_PORT_PARENT_ID,
 	SWDEV_ATTR_PORT_STP_STATE,
+	SWDEV_ATTR_PORT_BRIDGE_FLAGS,
 };
 
 struct swdev_attr {
@@ -29,6 +30,7 @@ struct swdev_attr {
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
+		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 	};
 };
 
-- 
1.7.10.4
