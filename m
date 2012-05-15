From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] isdn: Fix typo in hfcmulti.c
Date: Wed, 16 May 2012 04:06:39 +0900
Message-ID: <1337108799-14899-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, linux-kernel@vger.kernel.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correcting spelling "extenal" to "external" in hfcmulti.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 0332231..4df24a1 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -1156,7 +1156,7 @@ init_chip(struct hfc_multi *hc)
 	hc->DTMFbase = 0x1000;
 	if (test_bit(HFC_CHIP_EXRAM_128, &hc->chip)) {
 		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_DEBUG "%s: changing to 128K extenal RAM\n",
+			printk(KERN_DEBUG "%s: changing to 128K external RAM\n",
 			       __func__);
 		hc->hw.r_ctrl |= V_EXT_RAM;
 		hc->hw.r_ram_sz = 1;
@@ -1167,7 +1167,7 @@ init_chip(struct hfc_multi *hc)
 	}
 	if (test_bit(HFC_CHIP_EXRAM_512, &hc->chip)) {
 		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_DEBUG "%s: changing to 512K extenal RAM\n",
+			printk(KERN_DEBUG "%s: changing to 512K external RAM\n",
 			       __func__);
 		hc->hw.r_ctrl |= V_EXT_RAM;
 		hc->hw.r_ram_sz = 2;
-- 
1.7.10.2.520.g6a4a482
