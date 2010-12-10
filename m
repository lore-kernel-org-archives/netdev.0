From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 24/27] e1000e: minor error message corrections
Date: Fri, 10 Dec 2010 02:06:22 -0800
Message-ID: <1291975585-30576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:55321
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751004Ab0LJKGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:06:33 -0500
To: davem@davemloft.net
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Correct error messages when setting up Rx resources and when checking
module parameters.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 drivers/net/e1000e/param.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4bf843a..6e1f3a3 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2130,7 +2130,7 @@ err_pages:
 	}
 err:
 	vfree(rx_ring->buffer_info);
-	e_err("Unable to allocate memory for the transmit descriptor ring\n");
+	e_err("Unable to allocate memory for the receive descriptor ring\n");
 	return err;
 }
 
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 3d36911..a9612b0 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -421,7 +421,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		static const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "CRC Stripping",
-			.err  = "defaulting to enabled",
+			.err  = "defaulting to Enabled",
 			.def  = OPTION_ENABLED
 		};
 
-- 
1.7.3.2

