From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] bnx2x: Remove duplicate inclusion of bnx2x_hsi.h
Date: Mon, 19 Nov 2012 17:22:11 +0530
Message-ID: <1353325931-1803-1-git-send-email-sachin.kamat@linaro.org>
Cc: eilong@broadcom.com, davem@davemloft.net, sachin.kamat@linaro.org,
	patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:57006 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab2KSL6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 06:58:18 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so726965dak.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 03:58:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_hsi.h was included twice.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index de121cc..19517b3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -44,7 +44,6 @@
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
 #include "bnx2x_mfw_req.h"
-#include "bnx2x_hsi.h"
 #include "bnx2x_link.h"
 #include "bnx2x_sp.h"
 #include "bnx2x_dcb.h"
-- 
1.7.4.1
