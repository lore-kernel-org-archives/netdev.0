From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/12] e1000e: use static params to save stack
	space (part 2)
Date: Mon, 10 May 2010 17:59:10 -0700
Message-ID: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:38446 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754266Ab0EKA73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 20:59:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A couple stack cleanups missed in an earlier patch from Jesse.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/param.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 0f4077c..a150e48 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -286,7 +286,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Receive Interrupt Delay */
-		struct e1000_option opt = {
+		static struct e1000_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
 			.err  = "using default of "
@@ -386,7 +386,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		}
 	}
 	{ /* Interrupt Mode */
-		struct e1000_option opt = {
+		static struct e1000_option opt = {
 			.type = range_option,
 			.name = "Interrupt Mode",
 			.err  = "defaulting to 2 (MSI-X)",

