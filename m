From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 10/11] tg3: Fix eee preprocessor naming
Date: Tue, 25 Jan 2011 17:58:56 -0800
Message-ID: <1296007137-23146-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1820 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511Ab1AZB7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a preprocessor naming bug for one of the EEE registers.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 drivers/net/tg3.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eb90400..c7ac812 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7829,7 +7829,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		       TG3_CPMU_DBTMR1_LNKIDLE_2047US);
 
 		tw32_f(TG3_CPMU_EEE_DBTMR2,
-		       TG3_CPMU_DBTMR1_APE_TX_2047US |
+		       TG3_CPMU_DBTMR2_APE_TX_2047US |
 		       TG3_CPMU_DBTMR2_TXIDXEQ_2047US);
 	}
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 1dbe5ec..716fc00 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1106,7 +1106,7 @@
 #define  TG3_CPMU_DBTMR1_PCIEXIT_2047US	 0x07ff0000
 #define  TG3_CPMU_DBTMR1_LNKIDLE_2047US	 0x000070ff
 #define TG3_CPMU_EEE_DBTMR2		0x000036b8
-#define  TG3_CPMU_DBTMR1_APE_TX_2047US	 0x07ff0000
+#define  TG3_CPMU_DBTMR2_APE_TX_2047US	 0x07ff0000
 #define  TG3_CPMU_DBTMR2_TXIDXEQ_2047US	 0x000070ff
 #define TG3_CPMU_EEE_LNKIDL_CTRL	0x000036bc
 #define  TG3_CPMU_EEE_LNKIDL_PCIE_NL0	 0x01000000
-- 
1.7.2.2


