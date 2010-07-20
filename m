From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] e1000e: Drop a useless statement
Date: Tue, 20 Jul 2010 17:30:42 +0200
Message-ID: <201007201730.42852.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34549 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932355Ab0GTPap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 11:30:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

err is set again a few lines below.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
I sent this patch to the e1000-devel list on June 8th, 2010, but
didn't receive any answer:
http://sourceforge.net/mailarchive/forum.php?thread_name=201006081820.25381.jdelvare%40suse.de&forum_name=e1000-devel

 drivers/net/e1000e/netdev.c |    2 --
 1 file changed, 2 deletions(-)

--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5557,8 +5557,6 @@ static int __devinit e1000_probe(struct
 	if (err)
 		goto err_sw_init;
 
-	err = -EIO;
-
 	memcpy(&hw->mac.ops, ei->mac_ops, sizeof(hw->mac.ops));
 	memcpy(&hw->nvm.ops, ei->nvm_ops, sizeof(hw->nvm.ops));
 	memcpy(&hw->phy.ops, ei->phy_ops, sizeof(hw->phy.ops));

-- 
Jean Delvare
Suse L3
