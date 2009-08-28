From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/17] tg3: Reformat NVRAM case statements
Date: Fri, 28 Aug 2009 15:29:16 -0700
Message-ID: <1251585279.29669@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2439 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601AbZH2Wer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes up the NVRAM detection switch statements to conform
to the kernel coding style.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |  369 ++++++++++++++++++++++++++---------------------------
 1 files changed, 183 insertions(+), 186 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d43b30b..4c4d164 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10302,8 +10302,7 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 	nvcfg1 = tr32(NVRAM_CFG1);
 	if (nvcfg1 & NVRAM_CFG1_FLASHIF_ENAB) {
 		tp->tg3_flags2 |= TG3_FLG2_FLASH;
-	}
-	else {
+	} else {
 		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
 		tw32(NVRAM_CFG1, nvcfg1);
 	}
@@ -10311,37 +10310,36 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 		switch (nvcfg1 & NVRAM_CFG1_VENDOR_MASK) {
-			case FLASH_VENDOR_ATMEL_FLASH_BUFFERED:
-				tp->nvram_jedecnum = JEDEC_ATMEL;
-				tp->nvram_pagesize = ATMEL_AT45DB0X1B_PAGE_SIZE;
-				tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-				break;
-			case FLASH_VENDOR_ATMEL_FLASH_UNBUFFERED:
-				tp->nvram_jedecnum = JEDEC_ATMEL;
-                         	tp->nvram_pagesize = ATMEL_AT25F512_PAGE_SIZE;
-				break;
-			case FLASH_VENDOR_ATMEL_EEPROM:
-				tp->nvram_jedecnum = JEDEC_ATMEL;
-                         	tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
-				tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-				break;
-			case FLASH_VENDOR_ST:
-				tp->nvram_jedecnum = JEDEC_ST;
-				tp->nvram_pagesize = ST_M45PEX0_PAGE_SIZE;
-				tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-				break;
-			case FLASH_VENDOR_SAIFUN:
-				tp->nvram_jedecnum = JEDEC_SAIFUN;
-				tp->nvram_pagesize = SAIFUN_SA25F0XX_PAGE_SIZE;
-				break;
-			case FLASH_VENDOR_SST_SMALL:
-			case FLASH_VENDOR_SST_LARGE:
-				tp->nvram_jedecnum = JEDEC_SST;
-				tp->nvram_pagesize = SST_25VF0X0_PAGE_SIZE;
-				break;
+		case FLASH_VENDOR_ATMEL_FLASH_BUFFERED:
+			tp->nvram_jedecnum = JEDEC_ATMEL;
+			tp->nvram_pagesize = ATMEL_AT45DB0X1B_PAGE_SIZE;
+			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			break;
+		case FLASH_VENDOR_ATMEL_FLASH_UNBUFFERED:
+			tp->nvram_jedecnum = JEDEC_ATMEL;
+			tp->nvram_pagesize = ATMEL_AT25F512_PAGE_SIZE;
+			break;
+		case FLASH_VENDOR_ATMEL_EEPROM:
+			tp->nvram_jedecnum = JEDEC_ATMEL;
+			tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
+			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			break;
+		case FLASH_VENDOR_ST:
+			tp->nvram_jedecnum = JEDEC_ST;
+			tp->nvram_pagesize = ST_M45PEX0_PAGE_SIZE;
+			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			break;
+		case FLASH_VENDOR_SAIFUN:
+			tp->nvram_jedecnum = JEDEC_SAIFUN;
+			tp->nvram_pagesize = SAIFUN_SA25F0XX_PAGE_SIZE;
+			break;
+		case FLASH_VENDOR_SST_SMALL:
+		case FLASH_VENDOR_SST_LARGE:
+			tp->nvram_jedecnum = JEDEC_SST;
+			tp->nvram_pagesize = SST_25VF0X0_PAGE_SIZE;
+			break;
 		}
-	}
-	else {
+	} else {
 		tp->nvram_jedecnum = JEDEC_ATMEL;
 		tp->nvram_pagesize = ATMEL_AT45DB0X1B_PAGE_SIZE;
 		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
@@ -10359,48 +10357,47 @@ static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_PROTECTED_NVRAM;
 
 	switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
-		case FLASH_5752VENDOR_ATMEL_EEPROM_64KHZ:
-		case FLASH_5752VENDOR_ATMEL_EEPROM_376KHZ:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			break;
-		case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			break;
-		case FLASH_5752VENDOR_ST_M45PE10:
-		case FLASH_5752VENDOR_ST_M45PE20:
-		case FLASH_5752VENDOR_ST_M45PE40:
-			tp->nvram_jedecnum = JEDEC_ST;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			break;
+	case FLASH_5752VENDOR_ATMEL_EEPROM_64KHZ:
+	case FLASH_5752VENDOR_ATMEL_EEPROM_376KHZ:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		break;
+	case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		break;
+	case FLASH_5752VENDOR_ST_M45PE10:
+	case FLASH_5752VENDOR_ST_M45PE20:
+	case FLASH_5752VENDOR_ST_M45PE40:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		break;
 	}
 
 	if (tp->tg3_flags2 & TG3_FLG2_FLASH) {
 		switch (nvcfg1 & NVRAM_CFG1_5752PAGE_SIZE_MASK) {
-			case FLASH_5752PAGE_SIZE_256:
-				tp->nvram_pagesize = 256;
-				break;
-			case FLASH_5752PAGE_SIZE_512:
-				tp->nvram_pagesize = 512;
-				break;
-			case FLASH_5752PAGE_SIZE_1K:
-				tp->nvram_pagesize = 1024;
-				break;
-			case FLASH_5752PAGE_SIZE_2K:
-				tp->nvram_pagesize = 2048;
-				break;
-			case FLASH_5752PAGE_SIZE_4K:
-				tp->nvram_pagesize = 4096;
-				break;
-			case FLASH_5752PAGE_SIZE_264:
-				tp->nvram_pagesize = 264;
-				break;
+		case FLASH_5752PAGE_SIZE_256:
+			tp->nvram_pagesize = 256;
+			break;
+		case FLASH_5752PAGE_SIZE_512:
+			tp->nvram_pagesize = 512;
+			break;
+		case FLASH_5752PAGE_SIZE_1K:
+			tp->nvram_pagesize = 1024;
+			break;
+		case FLASH_5752PAGE_SIZE_2K:
+			tp->nvram_pagesize = 2048;
+			break;
+		case FLASH_5752PAGE_SIZE_4K:
+			tp->nvram_pagesize = 4096;
+			break;
+		case FLASH_5752PAGE_SIZE_264:
+			tp->nvram_pagesize = 264;
+			break;
 		}
-	}
-	else {
+	} else {
 		/* For eeprom, set pagesize to maximum eeprom size */
 		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 
@@ -10423,45 +10420,45 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 
 	nvcfg1 &= NVRAM_CFG1_5752VENDOR_MASK;
 	switch (nvcfg1) {
-		case FLASH_5755VENDOR_ATMEL_FLASH_1:
-		case FLASH_5755VENDOR_ATMEL_FLASH_2:
-		case FLASH_5755VENDOR_ATMEL_FLASH_3:
-		case FLASH_5755VENDOR_ATMEL_FLASH_5:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			tp->nvram_pagesize = 264;
-			if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_1 ||
-			    nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_5)
-				tp->nvram_size = (protect ? 0x3e200 :
-						  TG3_NVRAM_SIZE_512KB);
-			else if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_2)
-				tp->nvram_size = (protect ? 0x1f200 :
-						  TG3_NVRAM_SIZE_256KB);
-			else
-				tp->nvram_size = (protect ? 0x1f200 :
-						  TG3_NVRAM_SIZE_128KB);
-			break;
-		case FLASH_5752VENDOR_ST_M45PE10:
-		case FLASH_5752VENDOR_ST_M45PE20:
-		case FLASH_5752VENDOR_ST_M45PE40:
-			tp->nvram_jedecnum = JEDEC_ST;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			tp->nvram_pagesize = 256;
-			if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE10)
-				tp->nvram_size = (protect ?
-						  TG3_NVRAM_SIZE_64KB :
-						  TG3_NVRAM_SIZE_128KB);
-			else if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE20)
-				tp->nvram_size = (protect ?
-						  TG3_NVRAM_SIZE_64KB :
-						  TG3_NVRAM_SIZE_256KB);
-			else
-				tp->nvram_size = (protect ?
-						  TG3_NVRAM_SIZE_128KB :
-						  TG3_NVRAM_SIZE_512KB);
-			break;
+	case FLASH_5755VENDOR_ATMEL_FLASH_1:
+	case FLASH_5755VENDOR_ATMEL_FLASH_2:
+	case FLASH_5755VENDOR_ATMEL_FLASH_3:
+	case FLASH_5755VENDOR_ATMEL_FLASH_5:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tp->nvram_pagesize = 264;
+		if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_1 ||
+		    nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_5)
+			tp->nvram_size = (protect ? 0x3e200 :
+					  TG3_NVRAM_SIZE_512KB);
+		else if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_2)
+			tp->nvram_size = (protect ? 0x1f200 :
+					  TG3_NVRAM_SIZE_256KB);
+		else
+			tp->nvram_size = (protect ? 0x1f200 :
+					  TG3_NVRAM_SIZE_128KB);
+		break;
+	case FLASH_5752VENDOR_ST_M45PE10:
+	case FLASH_5752VENDOR_ST_M45PE20:
+	case FLASH_5752VENDOR_ST_M45PE40:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tp->nvram_pagesize = 256;
+		if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE10)
+			tp->nvram_size = (protect ?
+					  TG3_NVRAM_SIZE_64KB :
+					  TG3_NVRAM_SIZE_128KB);
+		else if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE20)
+			tp->nvram_size = (protect ?
+					  TG3_NVRAM_SIZE_64KB :
+					  TG3_NVRAM_SIZE_256KB);
+		else
+			tp->nvram_size = (protect ?
+					  TG3_NVRAM_SIZE_128KB :
+					  TG3_NVRAM_SIZE_512KB);
+		break;
 	}
 }
 
@@ -10472,34 +10469,34 @@ static void __devinit tg3_get_5787_nvram_info(struct tg3 *tp)
 	nvcfg1 = tr32(NVRAM_CFG1);
 
 	switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
-		case FLASH_5787VENDOR_ATMEL_EEPROM_64KHZ:
-		case FLASH_5787VENDOR_ATMEL_EEPROM_376KHZ:
-		case FLASH_5787VENDOR_MICRO_EEPROM_64KHZ:
-		case FLASH_5787VENDOR_MICRO_EEPROM_376KHZ:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
+	case FLASH_5787VENDOR_ATMEL_EEPROM_64KHZ:
+	case FLASH_5787VENDOR_ATMEL_EEPROM_376KHZ:
+	case FLASH_5787VENDOR_MICRO_EEPROM_64KHZ:
+	case FLASH_5787VENDOR_MICRO_EEPROM_376KHZ:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 
-			nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
-			tw32(NVRAM_CFG1, nvcfg1);
-			break;
-		case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
-		case FLASH_5755VENDOR_ATMEL_FLASH_1:
-		case FLASH_5755VENDOR_ATMEL_FLASH_2:
-		case FLASH_5755VENDOR_ATMEL_FLASH_3:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			tp->nvram_pagesize = 264;
-			break;
-		case FLASH_5752VENDOR_ST_M45PE10:
-		case FLASH_5752VENDOR_ST_M45PE20:
-		case FLASH_5752VENDOR_ST_M45PE40:
-			tp->nvram_jedecnum = JEDEC_ST;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			tp->nvram_pagesize = 256;
-			break;
+		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
+		tw32(NVRAM_CFG1, nvcfg1);
+		break;
+	case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
+	case FLASH_5755VENDOR_ATMEL_FLASH_1:
+	case FLASH_5755VENDOR_ATMEL_FLASH_2:
+	case FLASH_5755VENDOR_ATMEL_FLASH_3:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tp->nvram_pagesize = 264;
+		break;
+	case FLASH_5752VENDOR_ST_M45PE10:
+	case FLASH_5752VENDOR_ST_M45PE20:
+	case FLASH_5752VENDOR_ST_M45PE40:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tp->nvram_pagesize = 256;
+		break;
 	}
 }
 
@@ -10517,63 +10514,63 @@ static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
 
 	nvcfg1 &= NVRAM_CFG1_5752VENDOR_MASK;
 	switch (nvcfg1) {
-		case FLASH_5761VENDOR_ATMEL_ADB021D:
-		case FLASH_5761VENDOR_ATMEL_ADB041D:
-		case FLASH_5761VENDOR_ATMEL_ADB081D:
-		case FLASH_5761VENDOR_ATMEL_ADB161D:
-		case FLASH_5761VENDOR_ATMEL_MDB021D:
-		case FLASH_5761VENDOR_ATMEL_MDB041D:
-		case FLASH_5761VENDOR_ATMEL_MDB081D:
-		case FLASH_5761VENDOR_ATMEL_MDB161D:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
-			tp->nvram_pagesize = 256;
-			break;
-		case FLASH_5761VENDOR_ST_A_M45PE20:
-		case FLASH_5761VENDOR_ST_A_M45PE40:
-		case FLASH_5761VENDOR_ST_A_M45PE80:
-		case FLASH_5761VENDOR_ST_A_M45PE16:
-		case FLASH_5761VENDOR_ST_M_M45PE20:
-		case FLASH_5761VENDOR_ST_M_M45PE40:
-		case FLASH_5761VENDOR_ST_M_M45PE80:
-		case FLASH_5761VENDOR_ST_M_M45PE16:
-			tp->nvram_jedecnum = JEDEC_ST;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->tg3_flags2 |= TG3_FLG2_FLASH;
-			tp->nvram_pagesize = 256;
-			break;
+	case FLASH_5761VENDOR_ATMEL_ADB021D:
+	case FLASH_5761VENDOR_ATMEL_ADB041D:
+	case FLASH_5761VENDOR_ATMEL_ADB081D:
+	case FLASH_5761VENDOR_ATMEL_ADB161D:
+	case FLASH_5761VENDOR_ATMEL_MDB021D:
+	case FLASH_5761VENDOR_ATMEL_MDB041D:
+	case FLASH_5761VENDOR_ATMEL_MDB081D:
+	case FLASH_5761VENDOR_ATMEL_MDB161D:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tp->nvram_pagesize = 256;
+		break;
+	case FLASH_5761VENDOR_ST_A_M45PE20:
+	case FLASH_5761VENDOR_ST_A_M45PE40:
+	case FLASH_5761VENDOR_ST_A_M45PE80:
+	case FLASH_5761VENDOR_ST_A_M45PE16:
+	case FLASH_5761VENDOR_ST_M_M45PE20:
+	case FLASH_5761VENDOR_ST_M_M45PE40:
+	case FLASH_5761VENDOR_ST_M_M45PE80:
+	case FLASH_5761VENDOR_ST_M_M45PE16:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tp->nvram_pagesize = 256;
+		break;
 	}
 
 	if (protect) {
 		tp->nvram_size = tr32(NVRAM_ADDR_LOCKOUT);
 	} else {
 		switch (nvcfg1) {
-			case FLASH_5761VENDOR_ATMEL_ADB161D:
-			case FLASH_5761VENDOR_ATMEL_MDB161D:
-			case FLASH_5761VENDOR_ST_A_M45PE16:
-			case FLASH_5761VENDOR_ST_M_M45PE16:
-				tp->nvram_size = TG3_NVRAM_SIZE_2MB;
-				break;
-			case FLASH_5761VENDOR_ATMEL_ADB081D:
-			case FLASH_5761VENDOR_ATMEL_MDB081D:
-			case FLASH_5761VENDOR_ST_A_M45PE80:
-			case FLASH_5761VENDOR_ST_M_M45PE80:
-				tp->nvram_size = TG3_NVRAM_SIZE_1MB;
-				break;
-			case FLASH_5761VENDOR_ATMEL_ADB041D:
-			case FLASH_5761VENDOR_ATMEL_MDB041D:
-			case FLASH_5761VENDOR_ST_A_M45PE40:
-			case FLASH_5761VENDOR_ST_M_M45PE40:
-				tp->nvram_size = TG3_NVRAM_SIZE_512KB;
-				break;
-			case FLASH_5761VENDOR_ATMEL_ADB021D:
-			case FLASH_5761VENDOR_ATMEL_MDB021D:
-			case FLASH_5761VENDOR_ST_A_M45PE20:
-			case FLASH_5761VENDOR_ST_M_M45PE20:
-				tp->nvram_size = TG3_NVRAM_SIZE_256KB;
-				break;
+		case FLASH_5761VENDOR_ATMEL_ADB161D:
+		case FLASH_5761VENDOR_ATMEL_MDB161D:
+		case FLASH_5761VENDOR_ST_A_M45PE16:
+		case FLASH_5761VENDOR_ST_M_M45PE16:
+			tp->nvram_size = TG3_NVRAM_SIZE_2MB;
+			break;
+		case FLASH_5761VENDOR_ATMEL_ADB081D:
+		case FLASH_5761VENDOR_ATMEL_MDB081D:
+		case FLASH_5761VENDOR_ST_A_M45PE80:
+		case FLASH_5761VENDOR_ST_M_M45PE80:
+			tp->nvram_size = TG3_NVRAM_SIZE_1MB;
+			break;
+		case FLASH_5761VENDOR_ATMEL_ADB041D:
+		case FLASH_5761VENDOR_ATMEL_MDB041D:
+		case FLASH_5761VENDOR_ST_A_M45PE40:
+		case FLASH_5761VENDOR_ST_M_M45PE40:
+			tp->nvram_size = TG3_NVRAM_SIZE_512KB;
+			break;
+		case FLASH_5761VENDOR_ATMEL_ADB021D:
+		case FLASH_5761VENDOR_ATMEL_MDB021D:
+		case FLASH_5761VENDOR_ST_A_M45PE20:
+		case FLASH_5761VENDOR_ST_M_M45PE20:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
 		}
 	}
 }
-- 
1.6.3.3


