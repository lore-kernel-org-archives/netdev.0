From: akpm@linux-foundation.org
Subject: [patch 14/21] e1000e-avoid-duplicated-output-of-device-name-in-kernel-warning-fix
Date: Mon, 22 Sep 2008 14:52:23 -0700
Message-ID: <200809222152.m8MLqNtV031978@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	elendil@planet.nl, jeffrey.t.kirsher@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35917 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754036AbYIVV6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:58:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

hm.

Cc: Frans Pop <elendil@planet.nl>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/e1000e/netdev.c~e1000e-avoid-duplicated-output-of-device-name-in-kernel-warning-fix drivers/net/e1000e/netdev.c
--- a/drivers/net/e1000e/netdev.c~e1000e-avoid-duplicated-output-of-device-name-in-kernel-warning-fix
+++ a/drivers/net/e1000e/netdev.c
@@ -4671,7 +4671,7 @@ static void e1000_eeprom_checks(struct e
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
 	if (!(le16_to_cpu(buf) & (1 << 0))) {
 		/* Deep Smart Power Down (DSPD) */
-		dev_warn(&adapter->pdev-dev,
+		dev_warn(&adapter->pdev->dev,
 			 "Warning: detected DSPD enabled in EEPROM\n");
 	}
 
_
