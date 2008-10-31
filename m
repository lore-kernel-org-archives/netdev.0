From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] net: kconfig cleanup
Date: Fri, 31 Oct 2008 00:41:43 -0700
Message-ID: <20081031074143.25532.6078.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andrew Gallatin <gallatin@myri.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:36511 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750800AbYJaHmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:42:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bool kconfig option added to ixgbe and myri10ge for DCA is ambigous, so this
patch adds a description to the kconfig option.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Andrew Gallatin <gallatin@myri.com>
---

 drivers/net/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f749b40..b13a7ff 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2437,7 +2437,7 @@ config IXGBE
 	  will be called ixgbe.
 
 config IXGBE_DCA
-	bool
+	bool "Enable DCA"
 	default y
 	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
 
@@ -2489,7 +2489,7 @@ config MYRI10GE
 	  will be called myri10ge.
 
 config MYRI10GE_DCA
-	bool
+	bool "Enable DCA"
 	default y
 	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
 

