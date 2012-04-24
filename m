From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 1/4] mISDN: Fix NULL pointer bug in if-condition of mISDN_dsp
Date: Tue, 24 Apr 2012 14:51:49 +0200
Message-ID: <1335271912-5269-2-git-send-email-kkeil@linux-pingi.de>
References: <1335271912-5269-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Andreas Eversberg <jolly@eversberg.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:55195 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012Ab2DXMyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 08:54:40 -0400
In-Reply-To: <1335271912-5269-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <jolly@eversberg.eu>

Fix a bug (was introduced by a cut & paste error)
in cases when dsp->conf was NULL.

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
