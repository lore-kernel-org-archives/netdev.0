From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/44] drivers/isdn: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:26 -0800
Message-ID: <c7a38f65340aafb208d50fc3a781602c07aebb0c.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1142 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932587Ab0KODFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 22:05:31 -0500
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/hardware/mISDN/mISDNinfineon.c |    4 ++--
 drivers/isdn/hardware/mISDN/mISDNisar.c     |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/mISDNinfineon.c b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
index e90db88..bc0529a 100644
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -420,7 +420,7 @@ enable_hwirq(struct inf_hw *hw)
 		break;
 	case INF_NICCY:
 		val = inl((u32)hw->cfg.start + NICCY_IRQ_CTRL_REG);
-		val |= NICCY_IRQ_ENABLE;;
+		val |= NICCY_IRQ_ENABLE;
 		outl(val, (u32)hw->cfg.start + NICCY_IRQ_CTRL_REG);
 		break;
 	case INF_SCT_1:
@@ -924,7 +924,7 @@ setup_instance(struct inf_hw *card)
 		mISDNipac_init(&card->ipac, card);
 
 	if (card->ipac.isac.dch.dev.Bprotocols == 0)
-		goto error_setup;;
+		goto error_setup;
 
 	err = mISDN_register_device(&card->ipac.isac.dch.dev,
 		&card->pdev->dev, card->name);
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 38eb314..d13fa5b 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -264,7 +264,7 @@ load_firmware(struct isar_hw *isar, const u8 *buf, int size)
 			while (noc) {
 				val = le16_to_cpu(*sp++);
 				*mp++ = val >> 8;
-				*mp++ = val & 0xFF;;
+				*mp++ = val & 0xFF;
 				noc--;
 			}
 			spin_lock_irqsave(isar->hwlock, flags);
-- 
1.7.3.1.g432b3.dirty

