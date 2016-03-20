From: Colin King <colin.king@canonical.com>
Subject: [PATCH] brcmfmac: sdio: remove unused variable retry_limit
Date: Sun, 20 Mar 2016 17:34:52 +0000
Message-ID: <1458495292-17701-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33519 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbcCTRe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 13:34:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

retry_limit has never been used during the life of this driver, so
we may as well remove it as it is redundant.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
index 43fd3f4..cd92ba7 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
@@ -535,9 +535,6 @@ static int qcount[NUMPRIO];
 
 #define RETRYCHAN(chan) ((chan) == SDPCM_EVENT_CHANNEL)
 
-/* Retry count for register access failures */
-static const uint retry_limit = 2;
-
 /* Limit on rounding up frames */
 static const uint max_roundup = 512;
 
-- 
2.7.3
