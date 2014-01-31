From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH][trivial] vxlan: remove extra newline after function definition
Date: Fri, 31 Jan 2014 09:50:12 +0200
Message-ID: <1391154612-5682-1-git-send-email-dbaluta@ixiacom.com>
Cc: netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:41552 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbaAaHtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 02:49:00 -0500
Received: by mail-ea0-f180.google.com with SMTP id o10so2122759eaj.39
        for <netdev@vger.kernel.org>; Thu, 30 Jan 2014 23:48:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 drivers/net/vxlan.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 026a313..e933648 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -469,7 +469,6 @@ static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
 /* Look up Ethernet address in forwarding table */
 static struct vxlan_fdb *__vxlan_find_mac(struct vxlan_dev *vxlan,
 					const u8 *mac)
-
 {
 	struct hlist_head *head = vxlan_fdb_head(vxlan, mac);
 	struct vxlan_fdb *f;
-- 
1.7.10.4
