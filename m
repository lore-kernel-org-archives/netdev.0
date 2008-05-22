From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-2.6] phylib: do EXPORT_SYMBOL on get_phy_id
Date: Thu, 22 May 2008 12:43:50 -0400
Message-ID: <1211474630-1728-1-git-send-email-paul.gortmaker@windriver.com>
Cc: davej@redhat.com, afleming@freescale.com, jgarzik@pobox.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44586 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273AbYEVQnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 12:43:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cac1f3c8 factored out the code for get_phy_id so that it
could be reused in multiple places.  Turns out that some of the
users can be modular, so we need to export this symbol as well.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/phy/phy_device.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index ac3c01d..16a0e7d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -207,6 +207,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 
 	return 0;
 }
+EXPORT_SYMBOL(get_phy_id);
 
 /**
  * get_phy_device - reads the specified PHY device and returns its @phy_device struct
-- 
1.5.4.rc4.gcab31

