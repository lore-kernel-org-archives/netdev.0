From: Geunsik Lim <geunsik.lim@gmail.com>
Subject: [PATCH] Keep kernel coding style rule of hfs-s+/sp source
Date: Wed,  1 Feb 2012 15:59:53 +0900
Message-ID: <1328079593-19197-1-git-send-email-geunsik.lim@gmail.com>
Cc: Netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modified for kernel coding style rule of hfs-s+/sp device driver .
. reference: ./Documentation/CodingStyle

ex)
60 Don't put multiple statements on a single line unless you have
61 something to hide:
62
63         if (condition) do_this;
64           do_something_everytime;

Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
---
 drivers/isdn/hisax/hfc_sx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 156d7c6..7c41bd8 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -381,7 +381,7 @@ reset_hfcsx(struct IsdnCardState *cs)
 	Write_hfc(cs, HFCSX_INT_M1, cs->hw.hfcsx.int_m1);
 
 	/* Clear already pending ints */
-	if (Read_hfc(cs, HFCSX_INT_S1));
+	Read_hfc(cs, HFCSX_INT_S1);
 
 	Write_hfc(cs, HFCSX_STATES, HFCSX_LOAD_STATE | 2);	/* HFC ST 2 */
 	udelay(10);
@@ -411,7 +411,7 @@ reset_hfcsx(struct IsdnCardState *cs)
 	/* Finally enable IRQ output */
 	cs->hw.hfcsx.int_m2 = HFCSX_IRQ_ENABLE;
 	Write_hfc(cs, HFCSX_INT_M2, cs->hw.hfcsx.int_m2);
-	if (Read_hfc(cs, HFCSX_INT_S2));
+	Read_hfc(cs, HFCSX_INT_S2);
 }
 
 /***************************************************/
@@ -1286,7 +1286,7 @@ hfcsx_bh(struct work_struct *work)
 						cs->hw.hfcsx.int_m1 &= ~HFCSX_INTS_TIMER;
 						Write_hfc(cs, HFCSX_INT_M1, cs->hw.hfcsx.int_m1);
 						/* Clear already pending ints */
-						if (Read_hfc(cs, HFCSX_INT_S1));
+						Read_hfc(cs, HFCSX_INT_S1);
 
 						Write_hfc(cs, HFCSX_STATES, 4 | HFCSX_LOAD_STATE);
 						udelay(10);
-- 
1.7.8.1
