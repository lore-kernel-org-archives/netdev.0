From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: enic: use correct type specifier
Date: Sun, 31 Jul 2016 11:10:08 +0200
Message-ID: <1469956208-32629-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:50626 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbcGaJKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 05:10:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i is defined as unsigned.
So print it with %u.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index f15560a..48f82ab 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1566,7 +1566,7 @@ static int enic_request_intr(struct enic *enic)
 			intr = enic_msix_rq_intr(enic, i);
 			snprintf(enic->msix[intr].devname,
 				sizeof(enic->msix[intr].devname),
-				"%.11s-rx-%d", netdev->name, i);
+				"%.11s-rx-%u", netdev->name, i);
 			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[i];
 		}
@@ -1577,7 +1577,7 @@ static int enic_request_intr(struct enic *enic)
 			intr = enic_msix_wq_intr(enic, i);
 			snprintf(enic->msix[intr].devname,
 				sizeof(enic->msix[intr].devname),
-				"%.11s-tx-%d", netdev->name, i);
+				"%.11s-tx-%u", netdev->name, i);
 			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[wq];
 		}
-- 
2.8.1
