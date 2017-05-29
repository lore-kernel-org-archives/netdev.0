From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 01/13] nfp: add MAY_USE_DEVLINK dependency
Date: Sun, 28 May 2017 17:52:52 -0700
Message-ID: <20170529005304.20847-2-jakub.kicinski@netronome.com>
References: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35516 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdE2Ay3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 20:54:29 -0400
Received: by mail-pf0-f171.google.com with SMTP id n23so40367460pfb.2
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 17:54:29 -0700 (PDT)
In-Reply-To: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix build with DEVLINK=m and NFP=y.

Fixes: 1851f93fd2ee ("nfp: add devlink support")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/Kconfig b/drivers/net/ethernet/netronome/Kconfig
index 967d7ca8c28c..0d5a7b9203a4 100644
--- a/drivers/net/ethernet/netronome/Kconfig
+++ b/drivers/net/ethernet/netronome/Kconfig
@@ -19,6 +19,7 @@ config NFP
 	tristate "Netronome(R) NFP4000/NFP6000 NIC driver"
 	depends on PCI && PCI_MSI
 	depends on VXLAN || VXLAN=n
+	depends on MAY_USE_DEVLINK
 	---help---
 	  This driver supports the Netronome(R) NFP4000/NFP6000 based
 	  cards working as a advanced Ethernet NIC.  It works with both
-- 
2.11.0
