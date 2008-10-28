From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Define more Rx status bits
Date: Tue, 28 Oct 2008 22:30:23 +0900 (JST)
Message-ID: <20081028.223023.93205850.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:54316 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbYJ1NaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 09:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change does not change driver's behaviour, just make its debug
output a bit meaningful.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index df20caf..385b174 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -236,7 +236,7 @@ struct tc35815_regs {
 #define Rx_Halted	       0x00008000 /* Rx Halted			     */
 #define Rx_Good		       0x00004000 /* Rx Good			     */
 #define Rx_RxPar	       0x00002000 /* Rx Parity Error		     */
-			    /* 0x00001000    not use			     */
+#define Rx_TypePkt	       0x00001000 /* Rx Type Packet		     */
 #define Rx_LongErr	       0x00000800 /* Rx Long Error		     */
 #define Rx_Over		       0x00000400 /* Rx Overflow		     */
 #define Rx_CRCErr	       0x00000200 /* Rx CRC Error		     */
@@ -244,8 +244,9 @@ struct tc35815_regs {
 #define Rx_10Stat	       0x00000080 /* Rx 10Mbps Status		     */
 #define Rx_IntRx	       0x00000040 /* Rx Interrupt		     */
 #define Rx_CtlRecd	       0x00000020 /* Rx Control Receive		     */
+#define Rx_InLenErr	       0x00000010 /* Rx In Range Frame Length Error  */
 
-#define Rx_Stat_Mask	       0x0000EFC0 /* Rx All Status Mask		     */
+#define Rx_Stat_Mask	       0x0000FFF0 /* Rx All Status Mask		     */
 
 /* Int_En bit asign -------------------------------------------------------- */
 #define Int_NRAbtEn	       0x00000800 /* 1:Non-recoverable Abort Enable  */
-- 
1.5.6.3
