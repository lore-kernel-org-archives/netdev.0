From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] igb: make sensor info static
Date: Sat, 16 Mar 2013 09:56:06 -0700
Message-ID: <20130316095606.1c8465f5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:35268 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab3CPQ4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 12:56:10 -0400
Received: by mail-pb0-f51.google.com with SMTP id un15so5145808pbc.10
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 09:56:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial sparse warning.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c	2013-03-14 14:22:58.135958283 -0700
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c	2013-03-16 09:44:46.455461525 -0700
@@ -39,7 +39,7 @@
 #include <linux/pci.h>
 
 #ifdef CONFIG_IGB_HWMON
-struct i2c_board_info i350_sensor_info = {
+static struct i2c_board_info i350_sensor_info = {
 	I2C_BOARD_INFO("i350bb", (0Xf8 >> 1)),
 };
 
