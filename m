From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 03/12] bnxt_en: Add support for upgrading APE/NC-SI firmware via Ethtool FLASHDEV
Date: Sun, 27 Dec 2015 18:19:20 -0500
Message-ID: <1451258369-21543-4-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:65238 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbbL0XTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:32 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <swindell@broadcom.com>

NC-SI firmware of type apeFW (10) is now supported.

Signed-off-by: Rob Swindell <swindell@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 45bd628..ea94450 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -818,6 +818,9 @@ static int bnxt_flash_firmware(struct net_device *dev,
 	case BNX_DIR_TYPE_BOOTCODE_2:
 		code_type = CODE_BOOT;
 		break;
+	case BNX_DIR_TYPE_APE_FW:
+		code_type = CODE_MCTP_PASSTHRU;
+		break;
 	default:
 		netdev_err(dev, "Unsupported directory entry type: %u\n",
 			   dir_type);
-- 
1.8.3.1
