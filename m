From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/3] qlge: Fix some bit definitions for reset register.
Date: Mon,  5 Oct 2009 14:46:47 -0700
Message-ID: <1254779209-15174-2-git-send-email-ron.mercer@qlogic.com>
References: <1254779209-15174-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:7750 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754570AbZJEVxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 17:53:35 -0400
In-Reply-To: <1254779209-15174-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 30d5585..f470fb9 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -135,9 +135,9 @@ enum {
 	RST_FO_TFO = (1 << 0),
 	RST_FO_RR_MASK = 0x00060000,
 	RST_FO_RR_CQ_CAM = 0x00000000,
-	RST_FO_RR_DROP = 0x00000001,
-	RST_FO_RR_DQ = 0x00000002,
-	RST_FO_RR_RCV_FUNC_CQ = 0x00000003,
+	RST_FO_RR_DROP = 0x00000002,
+	RST_FO_RR_DQ = 0x00000004,
+	RST_FO_RR_RCV_FUNC_CQ = 0x00000006,
 	RST_FO_FRB = (1 << 12),
 	RST_FO_MOP = (1 << 13),
 	RST_FO_REG = (1 << 14),
-- 
1.6.0.2

