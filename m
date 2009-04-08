From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: correct debugging message on mii read timeout
Date: Wed,  8 Apr 2009 20:27:23 +0100
Message-ID: <1239218843-18653-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:60850 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752379AbZDHT1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 15:27:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the warning printed when a mii READ times out currently says "Timed out
waiting for MII write to finish".  This patch corrects this.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 6da6781..eb7db03 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -317,7 +317,7 @@ static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 			goto out;
 		}
 
-	SMSC_WARNING(HW, "Timed out waiting for MII write to finish");
+	SMSC_WARNING(HW, "Timed out waiting for MII read to finish");
 	reg = -EIO;
 
 out:
-- 
1.6.0.6

