From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2/5 2.4] e1000: remove unused function e1000_enable_mng_pass_thru
Date: Fri, 15 Oct 2004 06:51:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150528510.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_hw.c linux-2.4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.4/drivers/net/e1000/e1000_hw.c	2004-10-07 09:11:14.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.c	2004-10-07 09:11:17.000000000 -0700
@@ -5227,31 +5227,6 @@ e1000_set_vco_speed(struct e1000_hw *hw)
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
