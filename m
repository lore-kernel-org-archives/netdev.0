From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: wireless: ath: ath9k: remove unnecessary code
Date: Mon, 8 May 2017 22:48:14 -0500
Message-ID: <20170509034814.GA18034@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway23.websitewelcome.com ([192.185.48.84]:20642 "EHLO
        gateway23.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751250AbdEIELM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 00:11:12 -0400
Received: from cm2.websitewelcome.com (cm2.websitewelcome.com [192.185.178.13])
        by gateway23.websitewelcome.com (Postfix) with ESMTP id 2D8DF14A6E
        for <netdev@vger.kernel.org>; Mon,  8 May 2017 22:48:16 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name of an array used by itself will always return the array's address.
So this test will always evaluate as true.

Addresses-Coverity-ID: 1364903
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/wireless/ath/ath9k/eeprom.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index fb80ec8..5c3bc28 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -143,7 +143,7 @@ bool ath9k_hw_nvram_read(struct ath_hw *ah, u32 off, u16 *data)
 
 	if (ah->eeprom_blob)
 		ret = ath9k_hw_nvram_read_firmware(ah->eeprom_blob, off, data);
-	else if (pdata && !pdata->use_eeprom && pdata->eeprom_data)
+	else if (pdata && !pdata->use_eeprom)
 		ret = ath9k_hw_nvram_read_pdata(pdata, off, data);
 	else
 		ret = common->bus_ops->eeprom_read(common, off, data);
-- 
2.5.0
