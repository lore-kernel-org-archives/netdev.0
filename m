From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2/5 2.5] e1000: remove unused function e1000_enable_mng_pass_thru
Date: Fri, 15 Oct 2004 06:52:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150541200.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e1000/e1000_hw.c netdev-2.6/drivers/net/e1000.new/e1000_hw.c
--- netdev-2.6/drivers/net/e1000/e1000_hw.c	2004-10-07 13:59:52.000000000 -0700
+++ netdev-2.6/drivers/net/e1000.new/e1000_hw.c	2004-10-07 13:59:53.000000000 -0700
@@ -5221,31 +5221,6 @@ e1000_set_vco_speed(struct e1000_hw *hw)
     return E1000_SUCCESS;
 }
 
-/******************************************************************************
- * Verifies the hardware needs to allow ARPs to be processed by the host
- *
- * hw - Struct containing variables accessed by shared code
- *
- * returns: - TRUE/FALSE
- *
- *****************************************************************************/
-uint32_t
-e1000_enable_mng_pass_thru(struct e1000_hw *hw)
-{
-    uint32_t manc;
-
-    if (hw->asf_firmware_present) {
-        manc = E1000_READ_REG(hw, MANC);
-
-        if (!(manc & E1000_MANC_RCV_TCO_EN) ||
-            !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
-            return FALSE;
-        if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
-            return TRUE;
-    }
-    return FALSE;
-}
-
 static int32_t
 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 {
