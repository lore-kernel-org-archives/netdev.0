From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] ravb: fix RX queue #1 frame error counter name
Date: Fri, 04 Dec 2015 01:51:10 +0300
Message-ID: <2605754.h5jel2JHUq@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Rx queue #1 frame error counter name contains trailing underscore,
probably due to a typo...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo but I won't mind if it gets
merged to 'net-next.git' instead...

 drivers/net/ethernet/renesas/ravb_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -1037,7 +1037,7 @@ static const char ravb_gstrings_stats[][
 	"rx_queue_1_mcast_packets",
 	"rx_queue_1_errors",
 	"rx_queue_1_crc_errors",
-	"rx_queue_1_frame_errors_",
+	"rx_queue_1_frame_errors",
 	"rx_queue_1_length_errors",
 	"rx_queue_1_missed_errors",
 	"rx_queue_1_over_errors",

