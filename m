From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/12] tg3: Add support for 2 new selfboot
 formats
Date: Wed, 17 Feb 2010 17:16:56 -0800
Message-ID: <1266455825-16150-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3070 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135Ab0BRBRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new offsets to the bootcode version extraction code to
support NVRAM format versions 4 and 5.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 ++++++
 drivers/net/tg3.h |    4 ++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 051b18a..f08e4b8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12753,6 +12753,12 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 	case TG3_EEPROM_SB_REVISION_3:
 		offset = TG3_EEPROM_SB_F1R3_EDH_OFF;
 		break;
+	case TG3_EEPROM_SB_REVISION_4:
+		offset = TG3_EEPROM_SB_F1R4_EDH_OFF;
+		break;
+	case TG3_EEPROM_SB_REVISION_5:
+		offset = TG3_EEPROM_SB_F1R5_EDH_OFF;
+		break;
 	default:
 		return;
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b4fd596..ffc12b1 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1864,6 +1864,8 @@
 #define TG3_EEPROM_SB_REVISION_0	0x00000000
 #define TG3_EEPROM_SB_REVISION_2	0x00020000
 #define TG3_EEPROM_SB_REVISION_3	0x00030000
+#define TG3_EEPROM_SB_REVISION_4	0x00040000
+#define TG3_EEPROM_SB_REVISION_5	0x00050000
 #define TG3_EEPROM_MAGIC_HW		0xabcd
 #define TG3_EEPROM_MAGIC_HW_MSK		0xffff
 
@@ -1881,6 +1883,8 @@
 #define TG3_EEPROM_SB_F1R2_EDH_OFF	0x14
 #define TG3_EEPROM_SB_F1R2_MBA_OFF	0x10
 #define TG3_EEPROM_SB_F1R3_EDH_OFF	0x18
+#define TG3_EEPROM_SB_F1R4_EDH_OFF	0x1c
+#define TG3_EEPROM_SB_F1R5_EDH_OFF	0x20
 #define TG3_EEPROM_SB_EDH_MAJ_MASK	0x00000700
 #define TG3_EEPROM_SB_EDH_MAJ_SHFT	8
 #define TG3_EEPROM_SB_EDH_MIN_MASK	0x000000ff
-- 
1.6.4.4


