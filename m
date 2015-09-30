From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/8] amd-xgbe: Remove an unneeded semicolon on a
 switch statement
Date: Wed, 30 Sep 2015 08:52:38 -0500
Message-ID: <20150930135238.12605.13308.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0087.outbound.protection.outlook.com ([157.56.110.87]:25376
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753801AbbI3OHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:07:37 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove an unneeded semicolon at the end of a switch statement block.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index a4473d8..553e251 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2224,7 +2224,7 @@ static u64 xgbe_mmc_read(struct xgbe_prv_data *pdata, unsigned int reg_lo)
 
 	default:
 		read_hi = false;
-	};
+	}
 
 	val = XGMAC_IOREAD(pdata, reg_lo);
 
