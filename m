From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH] qlge: remove unecessary if statement
Date: Sun,  5 Jun 2011 19:44:13 -0500
Message-ID: <1307321053-21695-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta11.charter.net ([216.33.127.80]:57909 "EHLO
	mta11.charter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab1FFAoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 20:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the code always returns 'status' regardless, so if(status) check is unecessary.

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 drivers/net/qlge/qlge_ethtool.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 19b00fa..9b67bfe 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -650,8 +650,6 @@ static int ql_set_pauseparam(struct net_device *netdev,
 		return -EINVAL;
 
 	status = ql_mb_set_port_cfg(qdev);
-	if (status)
-		return status;
 	return status;
 }
 
-- 
1.7.2.5

