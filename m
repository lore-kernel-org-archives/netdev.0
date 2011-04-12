From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] e1000: Remove blink_led_start declaration
Date: Tue, 12 Apr 2011 16:28:22 -0700
Message-ID: <4DA4E016.1050800@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, NetDev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41250 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756225Ab1DLX2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:28:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is left over code.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/net/e1000/e1000_hw.h |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6/drivers/net/e1000/e1000_hw.h
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_hw.h
+++ linux-2.6/drivers/net/e1000/e1000_hw.h
@@ -386,7 +386,6 @@ s32 e1000_setup_led(struct e1000_hw *hw)
 s32 e1000_cleanup_led(struct e1000_hw *hw);
 s32 e1000_led_on(struct e1000_hw *hw);
 s32 e1000_led_off(struct e1000_hw *hw);
-s32 e1000_blink_led_start(struct e1000_hw *hw);
 
 /* Adaptive IFS Functions */
 
