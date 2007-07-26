From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.22 1/3]S2io: Mask spurious interrupts
Date: 25 Jul 2007 19:35:09 -0700
Message-ID: <1185417308.21141.33.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ram.vepa@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:56174 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbXGZAv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:51:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Mask single and double bit ETQ ecc errors to inhibit spurious interrupts.

(Resending; Removed HTML sections in the patch)

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
---
diff -Nurp 2.0.24.1/drivers/net/s2io-regs.h 2.0.24.1P1/drivers/net/s2io-regs.h
--- 2.0.24.1/drivers/net/s2io-regs.h	2007-07-20 16:13:29.000000000 -0700
+++ 2.0.24.1P1/drivers/net/s2io-regs.h	2007-07-20 16:18:27.000000000 -0700
@@ -747,10 +747,9 @@ struct XENA_dev_config {
 #define MC_ERR_REG_MIRI_CRI_ERR_1          BIT(23)
 #define MC_ERR_REG_SM_ERR                  BIT(31)
 #define MC_ERR_REG_ECC_ALL_SNG		   (BIT(2) | BIT(3) | BIT(4) | BIT(5) |\
-					    BIT(6) | BIT(7) | BIT(17) | BIT(19))
+					BIT(17) | BIT(19))
 #define MC_ERR_REG_ECC_ALL_DBL		   (BIT(10) | BIT(11) | BIT(12) |\
-					    BIT(13) | BIT(14) | BIT(15) |\
-					    BIT(18) | BIT(20))
+					BIT(13) | BIT(18) | BIT(20))
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 



