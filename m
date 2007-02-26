From: divy@chelsio.com
Subject: [PATCH 3/7] cxgb3 - FW version update
Date: Sun, 25 Feb 2007 16:32:37 -0800
Message-ID: <20070226003237.25670.76606.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:7649 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933721AbXBZAeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 19:34:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Update FW version to 3.2

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c   |    6 ++++--
 drivers/net/cxgb3/version.h |    2 ++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 365a7f5..eaa7a2e 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -884,11 +884,13 @@ int t3_check_fw_version(struct adapter *
 	major = G_FW_VERSION_MAJOR(vers);
 	minor = G_FW_VERSION_MINOR(vers);
 
-	if (type == FW_VERSION_T3 && major == 3 && minor == 1)
+	if (type == FW_VERSION_T3 && major == FW_VERSION_MAJOR &&
+	    minor == FW_VERSION_MINOR)
 		return 0;
 
 	CH_ERR(adapter, "found wrong FW version(%u.%u), "
-	       "driver needs version 3.1\n", major, minor);
+	       "driver needs version %u.%u\n", major, minor,
+	       FW_VERSION_MAJOR, FW_VERSION_MINOR);
 	return -EINVAL;
 }
 
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index 2b67dd5..782a6cf 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -36,4 +36,6 @@
 #define DRV_NAME "cxgb3"
 /* Driver version */
 #define DRV_VERSION "1.0"
+#define FW_VERSION_MAJOR 3
+#define FW_VERSION_MINOR 2
 #endif				/* __CHELSIO_VERSION_H */
