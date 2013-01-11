From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] tg3: missing break statement in tg3_get_5720_nvram_info()
Date: Fri, 11 Jan 2013 09:57:33 +0300
Message-ID: <20130111065733.GG13207@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	kernel-janitors@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31959 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab3AKG5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 01:57:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a missing break statement so FLASH_5762_EEPROM_HD gets treated
like FLASH_5762_EEPROM_LD.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Only needed in linux-next.

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bc4d989..642764e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13726,8 +13726,10 @@ static void tg3_get_5720_nvram_info(struct tg3 *tp)
 		switch (nvmpinstrp) {
 		case FLASH_5762_EEPROM_HD:
 			nvmpinstrp = FLASH_5720_EEPROM_HD;
+			break;
 		case FLASH_5762_EEPROM_LD:
 			nvmpinstrp = FLASH_5720_EEPROM_LD;
+			break;
 		}
 	}
 
