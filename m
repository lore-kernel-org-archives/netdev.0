From: Hans Wennborg <hans@hanshq.net>
Subject: [PATCH 02/19] drivers: atm: fix %d confusingly prefixed with 0x in format strings
Date: Sun,  3 Aug 2014 17:18:20 -0700
Message-ID: <1407111500-14547-1-git-send-email-hans@hanshq.net>
Cc: Hans Wennborg <hans@hanshq.net>
To: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s87.loopia.se ([194.9.94.112]:29765 "EHLO s87.loopia.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767AbaHDASk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2014 20:18:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hans Wennborg <hans@hanshq.net>
---
 drivers/atm/eni.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index b1955ba..d65975a 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2155,7 +2155,7 @@ static int eni_proc_read(struct atm_dev *dev,loff_t *pos,char *page)
 
 		if (!tx->send) continue;
 		if (!--left) {
-			return sprintf(page,"tx[%d]:    0x%ld-0x%ld "
+			return sprintf(page, "tx[%d]:    0x%lx-0x%lx "
 			    "(%6ld bytes), rsv %d cps, shp %d cps%s\n",i,
 			    (unsigned long) (tx->send - eni_dev->ram),
 			    tx->send-eni_dev->ram+tx->words*4-1,tx->words*4,
@@ -2181,7 +2181,7 @@ static int eni_proc_read(struct atm_dev *dev,loff_t *pos,char *page)
 			if (--left) continue;
 			length = sprintf(page,"vcc %4d: ",vcc->vci);
 			if (eni_vcc->rx) {
-				length += sprintf(page+length,"0x%ld-0x%ld "
+				length += sprintf(page+length, "0x%lx-0x%lx "
 				    "(%6ld bytes)",
 				    (unsigned long) (eni_vcc->recv - eni_dev->ram),
 				    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
-- 
2.0.0.526.g5318336
