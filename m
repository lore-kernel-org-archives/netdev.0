From: sfeldma@gmail.com
Subject: [PATCH net-next v3 1/4] switchdev: add bridge ageing_time attribute
Date: Thu,  8 Oct 2015 19:23:17 -0700
Message-ID: <1444357400-37078-2-git-send-email-sfeldma@gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35968 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbJICUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:20:23 -0400
Received: by pablk4 with SMTP id lk4so71454148pab.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:20:23 -0700 (PDT)
In-Reply-To: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Setting the stage to push bridge-level attributes down to port driver so
hardware can be programmed accordingly.  Bridge-level attribute example is
ageing_time.  This is a per-bridge attribute, not a per-bridge-port attr.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 89266a3..61f129b 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -43,6 +43,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
 	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
+	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 };
 
 struct switchdev_attr {
@@ -52,6 +53,7 @@ struct switchdev_attr {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
+		u32 ageing_time;			/* BRIDGE_AGEING_TIME */
 	} u;
 };
 
-- 
1.7.10.4
