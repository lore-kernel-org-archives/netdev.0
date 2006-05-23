From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/6] e1000: remove backslash r debug printfs
Date: Tue, 23 May 2006 14:08:42 -0700
Message-ID: <20060523210842.18540.49393.stgit@gitlost.site>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:58885 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932236AbWEWVDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:44 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This removes unwanted characters in the debug output that should have
never been there.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 4c796e5..2e211df 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -2493,10 +2493,10 @@ e1000_config_fc_after_link_up(struct e10
                  */
                 if(hw->original_fc == e1000_fc_full) {
                     hw->fc = e1000_fc_full;
-                    DEBUGOUT("Flow Control = FULL.\r\n");
+                    DEBUGOUT("Flow Control = FULL.\n");
                 } else {
                     hw->fc = e1000_fc_rx_pause;
-                    DEBUGOUT("Flow Control = RX PAUSE frames only.\r\n");
+                    DEBUGOUT("Flow Control = RX PAUSE frames only.\n");
                 }
             }
             /* For receiving PAUSE frames ONLY.
@@ -2512,7 +2512,7 @@ e1000_config_fc_after_link_up(struct e10
                     (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
                     (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
                 hw->fc = e1000_fc_tx_pause;
-                DEBUGOUT("Flow Control = TX PAUSE frames only.\r\n");
+                DEBUGOUT("Flow Control = TX PAUSE frames only.\n");
             }
             /* For transmitting PAUSE frames ONLY.
              *
@@ -2527,7 +2527,7 @@ e1000_config_fc_after_link_up(struct e10
                     !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
                     (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
                 hw->fc = e1000_fc_rx_pause;
-                DEBUGOUT("Flow Control = RX PAUSE frames only.\r\n");
+                DEBUGOUT("Flow Control = RX PAUSE frames only.\n");
             }
             /* Per the IEEE spec, at this point flow control should be
              * disabled.  However, we want to consider that we could
@@ -2553,10 +2553,10 @@ e1000_config_fc_after_link_up(struct e10
                      hw->original_fc == e1000_fc_tx_pause) ||
                     hw->fc_strict_ieee) {
                 hw->fc = e1000_fc_none;
-                DEBUGOUT("Flow Control = NONE.\r\n");
+                DEBUGOUT("Flow Control = NONE.\n");
             } else {
                 hw->fc = e1000_fc_rx_pause;
-                DEBUGOUT("Flow Control = RX PAUSE frames only.\r\n");
+                DEBUGOUT("Flow Control = RX PAUSE frames only.\n");
             }
 
             /* Now we need to do one last check...  If we auto-
@@ -2581,7 +2581,7 @@ e1000_config_fc_after_link_up(struct e10
                 return ret_val;
             }
         } else {
-            DEBUGOUT("Copper PHY and Auto Neg has not completed.\r\n");
+            DEBUGOUT("Copper PHY and Auto Neg has not completed.\n");
         }
     }
     return E1000_SUCCESS;
@@ -2764,7 +2764,7 @@ e1000_check_for_link(struct e1000_hw *hw
             hw->autoneg_failed = 1;
             return 0;
         }
-        DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\r\n");
+        DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
 
         /* Disable auto-negotiation in the TXCW register */
         E1000_WRITE_REG(hw, TXCW, (hw->txcw & ~E1000_TXCW_ANE));
@@ -2789,7 +2789,7 @@ e1000_check_for_link(struct e1000_hw *hw
     else if(((hw->media_type == e1000_media_type_fiber) ||
              (hw->media_type == e1000_media_type_internal_serdes)) &&
             (ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
-        DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\r\n");
+        DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
         E1000_WRITE_REG(hw, TXCW, hw->txcw);
         E1000_WRITE_REG(hw, CTRL, (ctrl & ~E1000_CTRL_SLU));
 
@@ -2852,13 +2852,13 @@ e1000_get_speed_and_duplex(struct e1000_
 
         if(status & E1000_STATUS_FD) {
             *duplex = FULL_DUPLEX;
-            DEBUGOUT("Full Duplex\r\n");
+            DEBUGOUT("Full Duplex\n");
         } else {
             *duplex = HALF_DUPLEX;
-            DEBUGOUT(" Half Duplex\r\n");
+            DEBUGOUT(" Half Duplex\n");
         }
     } else {
-        DEBUGOUT("1000 Mbs, Full Duplex\r\n");
+        DEBUGOUT("1000 Mbs, Full Duplex\n");
         *speed = SPEED_1000;
         *duplex = FULL_DUPLEX;
     }



--
Auke Kok <auke-jan.h.kok@intel.com>
