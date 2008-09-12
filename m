From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 29/29] ixgbe: fix DCA dependency in Kconfig
Date: Thu, 11 Sep 2008 20:06:15 -0700
Message-ID: <20080912030558.6234.82574.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:19077 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbYILDGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:06:17 -0400
Received: by rv-out-0506.google.com with SMTP id k40so615516rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:06:17 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgbe can depend on dca IF it is enabled.  So if we are compiled as
IXGBE=y, and DCA is enabled, then we must force INTEL_IOATDMA and therefore
DCA to be =y also.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8831d13..826e556 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2380,6 +2380,7 @@ config EHEA
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
+	select INTEL_IOATDMA
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go

