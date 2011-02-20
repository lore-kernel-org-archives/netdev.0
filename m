From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: Add a missing bit for PXP parity
 register of 57712.
Date: Sun, 20 Feb 2011 16:27:05 +0200
Message-ID: <201102201627.05803.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
To: "Dave Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4037 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805Ab1BTO12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 09:27:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_init.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_init.h b/drivers/net/bnx2x/bnx2x_init.h
index 5a268e9..fa6dbe3 100644
--- a/drivers/net/bnx2x/bnx2x_init.h
+++ b/drivers/net/bnx2x/bnx2x_init.h
@@ -241,7 +241,7 @@ static const struct {
 	/* Block IGU, MISC, PXP and PXP2 parity errors as long as we don't
 	 * want to handle "system kill" flow at the moment.
 	 */
-	BLOCK_PRTY_INFO(PXP, 0x3ffffff, 0x3ffffff, 0x3ffffff, 0x3ffffff),
+	BLOCK_PRTY_INFO(PXP, 0x7ffffff, 0x3ffffff, 0x3ffffff, 0x7ffffff),
 	BLOCK_PRTY_INFO_0(PXP2,	0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff),
 	BLOCK_PRTY_INFO_1(PXP2,	0x7ff, 0x7f, 0x7f, 0x7ff),
 	BLOCK_PRTY_INFO(HC, 0x7, 0x7, 0x7, 0),
-- 
1.7.0.4


