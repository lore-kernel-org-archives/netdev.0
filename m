From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 07/10] switchdev: remove "NONE" transaction phase
Date: Thu, 24 Sep 2015 10:02:46 +0200
Message-ID: <1443081769-11193-8-git-send-email-jiri@resnulli.us>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37956 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbbIXIDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:03:01 -0400
Received: by wiclk2 with SMTP id lk2so101457843wic.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:03:00 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
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
