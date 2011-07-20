From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/8] tg3: Fix NVRAM selftest failures for 5720
 devs
Date: Wed, 20 Jul 2011 13:20:57 -0700
Message-ID: <1311193257-20531-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2274 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724Ab1GTUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes NVRAM selftest failures for 5720 devices by fixing the
checksum area size.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bce0f226..8035765 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10655,7 +10655,7 @@ error:
 #define NVRAM_SELFBOOT_FORMAT1_3_SIZE	0x1c
 #define NVRAM_SELFBOOT_FORMAT1_4_SIZE	0x20
 #define NVRAM_SELFBOOT_FORMAT1_5_SIZE	0x24
-#define NVRAM_SELFBOOT_FORMAT1_6_SIZE	0x4c
+#define NVRAM_SELFBOOT_FORMAT1_6_SIZE	0x50
 #define NVRAM_SELFBOOT_HW_SIZE 0x20
 #define NVRAM_SELFBOOT_DATA_SIZE 0x1c
 
-- 
1.7.3.4


