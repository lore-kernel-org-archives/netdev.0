From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 4/9] be2net: fix wrong return value in be_check_ufi_compatibility()
Date: Fri, 10 Jul 2015 05:32:46 -0400
Message-ID: <1436520771-11656-5-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56755 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753414AbbGJJ0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:33 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@avagotech.com>

In the commit a6e6ff6eee12f3e
("be2net: simplify UFI compatibility checking"), a return value of "-1"
was incorrectly used in place of "false". This patch fixes it.

Fixes: a6e6ff6eee12f3e ("be2net: simplify UFI compatibility checking")
Signed-off-by: Vasundhara Volam <vasundhara.volam@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8b81e23..8ef7ea5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4918,7 +4918,7 @@ static bool be_check_ufi_compatibility(struct be_adapter *adapter,
 {
 	if (!fhdr) {
 		dev_err(&adapter->pdev->dev, "Invalid FW UFI file");
-		return -1;
+		return false;
 	}
 
 	/* First letter of the build version is used to identify
-- 
2.4.1
