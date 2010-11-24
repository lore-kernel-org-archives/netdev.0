From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 10/10] tg3: Remove tg3_config_info definition
Date: Wed, 24 Nov 2010 10:31:54 -0800
Message-ID: <1290623514-18193-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3953 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754158Ab0KXScN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure isn't used anywhere in the driver.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 2938d18..59b0e09 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2564,10 +2564,6 @@ struct ring_info {
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
-struct tg3_config_info {
-	u32				flags;
-};
-
 struct tg3_link_config {
 	/* Describes what we're trying to get. */
 	u32				advertising;
-- 
1.7.2.2


