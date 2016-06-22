From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: tc35815: fix spelling mistake on "descriptors"
Date: Wed, 22 Jun 2016 17:42:21 +0100
Message-ID: <1466613741-23607-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fixes to spelling mistakes of the word "descriptors"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/toshiba/tc35815.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 5487478..74e6719 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -280,7 +280,7 @@ struct tc35815_regs {
  * Descriptors
  */
 
-/* Frame descripter */
+/* Frame descriptor */
 struct FDesc {
 	volatile __u32 FDNext;
 	volatile __u32 FDSystem;
@@ -288,7 +288,7 @@ struct FDesc {
 	volatile __u32 FDCtl;
 };
 
-/* Buffer descripter */
+/* Buffer descriptor */
 struct BDesc {
 	volatile __u32 BuffData;
 	volatile __u32 BDCtl;
@@ -296,7 +296,7 @@ struct BDesc {
 
 #define FD_ALIGN	16
 
-/* Frame Descripter bit assign ---------------------------------------------- */
+/* Frame Descriptor bit assign ---------------------------------------------- */
 #define FD_FDLength_MASK       0x0000FFFF /* Length MASK		     */
 #define FD_BDCnt_MASK	       0x001F0000 /* BD count MASK in FD	     */
 #define FD_FrmOpt_MASK	       0x7C000000 /* Frame option MASK		     */
@@ -309,7 +309,7 @@ struct BDesc {
 #define FD_Next_EOL	       0x00000001 /* FD EOL indicator		     */
 #define FD_BDCnt_SHIFT	       16
 
-/* Buffer Descripter bit assign --------------------------------------------- */
+/* Buffer Descriptor bit assign --------------------------------------------- */
 #define BD_BuffLength_MASK     0x0000FFFF /* Receive Data Size		     */
 #define BD_RxBDID_MASK	       0x00FF0000 /* BD ID Number MASK		     */
 #define BD_RxBDSeqN_MASK       0x7F000000 /* Rx BD Sequence Number	     */
@@ -1387,7 +1387,7 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
 	if (status & Int_IntExBD) {
 		if (netif_msg_rx_err(lp))
 			dev_warn(&dev->dev,
-				 "Excessive Buffer Descriptiors (%#x).\n",
+				 "Excessive Buffer Descriptors (%#x).\n",
 				 status);
 		dev->stats.rx_length_errors++;
 		ret = 0;
-- 
2.8.1
