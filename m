From: Luis de Bethencourt <luisbg@ubuntu.com>
Subject: [PATCH 2/2] ath: fix code readability in regd.c
Date: Tue, 30 Mar 2010 16:44:33 +0100
Message-ID: <1269963873-2070-1-git-send-email-luisbg@ubuntu.com>
References: <ath/regd.c>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Luis de Bethencourt <luisbg@ubuntu.com>
To: linville@tuxdriver.com, lrodriguez@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:47624 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126Ab0C3Pom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 11:44:42 -0400
In-Reply-To: <ath/regd.c>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch to the ath/regd.c file that fixes two code
readability issues. A space between to separate two defines
and the indentation inside the ath_redg_is_eeprom_valid
function.

Signed-off-by: Luis de Bethencourt <luisbg@ubuntu.com>
---
 drivers/net/wireless/ath/regd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/regd.c
index 04abd1f..d5c2332 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -51,6 +51,7 @@
 
 #define ATH9K_5GHZ_ALL		ATH9K_5GHZ_5150_5350, \
 				ATH9K_5GHZ_5470_5850
+
 /* This one skips what we call "mid band" */
 #define ATH9K_5GHZ_NO_MIDBAND	ATH9K_5GHZ_5150_5350, \
 				ATH9K_5GHZ_5725_5850
@@ -361,7 +362,7 @@ EXPORT_SYMBOL(ath_reg_notifier_apply);
 
 static bool ath_regd_is_eeprom_valid(struct ath_regulatory *reg)
 {
-	 u16 rd = ath_regd_get_eepromRD(reg);
+	u16 rd = ath_regd_get_eepromRD(reg);
 	int i;
 
 	if (rd & COUNTRY_ERD_FLAG) {
-- 
1.6.3.3

