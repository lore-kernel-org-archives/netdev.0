From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: increase POST timeout for EEH recovery
Date: Wed, 26 May 2010 12:30:48 +0530
Message-ID: <20100526070048.GA2312@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:16390 "EHLO
	ubuntu.ubuntu-domain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932536Ab0EZHJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 03:09:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes BE requires longer time for POST completion after an EEH reset.
Increasing the timeout value accordingly.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index c911bfb..9d11dbf 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -294,7 +294,7 @@ int be_cmd_POST(struct be_adapter *adapter)
 		} else {
 			return 0;
 		}
-	} while (timeout < 20);
+	} while (timeout < 40);
 
 	dev_err(&adapter->pdev->dev, "POST timeout; stage=0x%x\n", stage);
 	return -1;
-- 
1.6.5.2

