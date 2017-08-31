From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] devlink: Maintain consistency in mac field name
Date: Wed, 30 Aug 2017 17:07:30 -0700
Message-ID: <1504138050-20170-1-git-send-email-dsahern@gmail.com>
Cc: arkadis@mellanox.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32899 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdHaAHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:07:37 -0400
Received: by mail-pg0-f66.google.com with SMTP id m15so6127414pgc.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:07:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 name uses "destination ip" as does the IPv6 patch set.
Make the mac field consistent.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/devlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 47931a202a0c..7d430c1d9c3e 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -31,7 +31,7 @@
 
 static struct devlink_dpipe_field devlink_dpipe_fields_ethernet[] = {
 	{
-		.name = "destination_mac",
+		.name = "destination mac",
 		.id = DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
 		.bitwidth = 48,
 	},
-- 
2.1.4
