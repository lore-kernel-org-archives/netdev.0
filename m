From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 07/10] switchdev: remove "NONE" transaction phase
Date: Wed, 23 Sep 2015 09:57:55 +0200
Message-ID: <1442995078-10491-8-git-send-email-jiri@resnulli.us>
References: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33446 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbbIWH6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 03:58:14 -0400
Received: by wiclk2 with SMTP id lk2so226631523wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 00:58:13 -0700 (PDT)
In-Reply-To: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Shouldn't have been there in the first place. Now it is unused, kill it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index f84ecf4..f61ee38 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -18,7 +18,6 @@
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 
 enum switchdev_trans_ph {
-	SWITCHDEV_TRANS_NONE,
 	SWITCHDEV_TRANS_PREPARE,
 	SWITCHDEV_TRANS_ABORT,
 	SWITCHDEV_TRANS_COMMIT,
-- 
1.9.3
