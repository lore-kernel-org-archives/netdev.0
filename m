From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 2/2] tc35815: Enable NAPI
Date: Mon, 26 Oct 2009 22:46:22 +0900
Message-ID: <1256564782-2781-2-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:58125 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbZJZNqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 09:46:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has NAPI code but it has been disabled.  Enable it now.
The non-napi code will be removed lator.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 3d38479..0d621ca 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -22,6 +22,7 @@
  * All Rights Reserved.
  */
 
+#define TC35815_NAPI
 #ifdef TC35815_NAPI
 #define DRV_VERSION	"1.38-NAPI"
 #else
-- 
1.5.6.5

