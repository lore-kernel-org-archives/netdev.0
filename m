From: sfeldma@gmail.com
Subject: [PATCH net-next 3/4] switchdev: documentation: for static FDB ops, use switchdev_port_fdb_xxx ops
Date: Wed,  3 Jun 2015 20:43:42 -0700
Message-ID: <1433389423-58467-4-git-send-email-sfeldma@gmail.com>
References: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35732 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbFDDlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:41:47 -0400
Received: by padjw17 with SMTP id jw17so20371922pad.2
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 20:41:47 -0700 (PDT)
In-Reply-To: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 0554b68..00c703c 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -177,6 +177,10 @@ entries are installed, for example, using iproute2 bridge cmd:
 
 	bridge fdb add ADDR dev DEV [vlan VID] [self]
 
+The driver should use the helper switchdev_port_fdb_xxx ops for ndo_fdb_xxx
+ops, and handle add/delete/dump of SWITCHDEV_OBJ_PORT_FDB object using
+switchdev_port_obj_xxx ops.
+
 XXX: what should be done if offloading this rule to hardware fails (for
 example, due to full capacity in hardware tables) ?
 
-- 
1.7.10.4
