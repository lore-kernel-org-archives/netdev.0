From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] bonding: remove unnecessary return
Date: Thu, 20 Apr 2017 00:08:23 -0400
Message-ID: <1492661303-19755-1-git-send-email-yanjun.zhu@oracle.com>
To: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45336 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdDTEIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 00:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The type of the function bond_update_speed_duplex is void.
So the return in the end of the function should be removed.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/bonding/bond_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8a4ba8b..af9f0ce 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -399,8 +399,6 @@ static void bond_update_speed_duplex(struct slave *slave)
 
 	slave->speed = ecmd.base.speed;
 	slave->duplex = ecmd.base.duplex;
-
-	return;
 }
 
 const char *bond_slave_link_status(s8 link)
-- 
2.7.4
