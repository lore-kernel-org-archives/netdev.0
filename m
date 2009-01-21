From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 5/9] bnx2x: trivial annotation of local variable.
Date: Tue, 20 Jan 2009 21:50:49 -0800
Message-ID: <1232517049.9701.23.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:23543 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbZAUFu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:58 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4192305wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 021c31c..f37c8ff 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8872,7 +8872,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x778,  0x70 },
 		{     0,     0 }
 	};
-	u32 buf[0x350 / 4];
+	__be32 buf[0x350 / 4];
 	u8 *data = (u8 *)buf;
 	int i, rc;
 	u32 magic, csum;
-- 
1.6.1.249.g455e5


