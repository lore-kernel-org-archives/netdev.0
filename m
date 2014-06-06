From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] isdn: mISDN: dsp_cmx.c:  Cleaning up a define that is no longer available
Date: Sat,  7 Jun 2014 01:25:30 +0200
Message-ID: <1402097131-10954-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:61028 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbaFFXYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 19:24:36 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so3511626wgg.12
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 16:24:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes an ifdef that is no longer available,
and that would cause a compile error if it was activated.

This was partly found using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/isdn/mISDN/dsp_cmx.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index a4f05c5..9e9bdc0 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1511,9 +1511,6 @@ dsp_cmx_send_member(struct dsp *dsp, int len, s32 *c, int members)
 			dsp->tx_R = t;
 			goto send_packet;
 		}
-#ifdef DSP_NEVER_DEFINED
-	}
-#endif
 	/* PROCESS DATA (three or more members) */
 	/* -> if echo is NOT enabled */
 	if (!dsp->echo.software) {
-- 
1.7.10.4
