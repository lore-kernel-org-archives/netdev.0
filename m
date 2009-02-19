From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: driver loads firmware v1.4 instead of v1.3
Date: Thu, 19 Feb 2009 14:40:29 -0800
Message-ID: <1235083229-25620-1-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:48206 "EHLO
	inaky-mobl3" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751191AbZBTCal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 21:30:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a one liner change to have the driver use by default the v1.4
of the i2400m firmware instead of v1.3. The v1.4 version of the
firmware has been submitted to David Woodhouse for inclusion in the
linux-firmware tree and it is already available at
http://linuxwimax.org/Download.

The reason for this change is that the 1.3 release of the user space
software and firmware has a few issues that will make it difficult to
use with currently deployed commercial networks such as Xohm and
Clearwire.

As well, the new 1.4 release of the user space software (which matches
the 1.4 firmware) has intermitent issues with the 1.3 firmware.

The 1.4 release in http://linuxwimax.org/Download has been widely
deployed and tested with the codebase in 2.6.29-rc, the 1.4 firmware
and the 1.4 user space components.

We understand it is quite late in the rc process for such a change,
but would like to ask for the change to be taken into consideration.

Alternatively, a user could always force feed a 1.4 firmware into a
driver that doesn't have this modification by:

$ cd /lib/firmware
$ mv i2400m-fw-usb-1.3.sbcf i2400m-fw-usb-1.3.real.sbcf
$ ln -sf i2400m-fw-usb-1.4.sbc i2400m-fw-usb-1.3.sbcf

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 067c871..3b9d27e 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -157,7 +157,7 @@ enum {
 
 
 /* Firmware version we request when pulling the fw image file */
-#define I2400M_FW_VERSION "1.3"
+#define I2400M_FW_VERSION "1.4"
 
 
 /**
-- 
1.5.6.5

