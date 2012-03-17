From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 01/28] mISDN: Fix NULL pointer bug in if-condition of mISDN_dsp
Date: Sat, 17 Mar 2012 10:27:41 +0100
Message-ID: <20120423170549.4CF8B9FB78@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:59411 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <jolly@eversberg.eu>
Fix bug in cases where dsp->conf was NULL.

Signed-off-by: Andreas Eversberg <jolly@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/dsp_cmx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 334feab..b7589c2 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1328,7 +1328,7 @@ dsp_cmx_send_member(struct dsp *dsp, int len, s32 *c, int members)
 		}
 		if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
 			tx_data_only = 1;
-		if (dsp->conf->software && dsp->echo.hardware)
+		if (dsp->echo.software && dsp->echo.hardware)
 			tx_data_only = 1;
 	}
 
-- 
1.7.3.4
