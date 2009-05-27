From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/6]: phy: Eliminate references to BUS_ID_SIZE.
Date: Tue, 26 May 2009 21:40:03 -0700 (PDT)
Message-ID: <20090526.214003.113600716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753406AbZE0EkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:40:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just use the constant 20 to keep things working.

If someone is so motivated, this can be converted over to
dynamic strings.  I tried and it's a lot of work.

But for now this is good enough.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/phy.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index c216e4e..b1368b8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -79,7 +79,7 @@ typedef enum {
  * Need to be a little smaller than phydev->dev.bus_id to leave room
  * for the ":%02x"
  */
-#define MII_BUS_ID_SIZE	(BUS_ID_SIZE - 3)
+#define MII_BUS_ID_SIZE	(20 - 3)
 
 /*
  * The Bus class for PHYs.  Devices which provide access to
@@ -407,7 +407,7 @@ struct phy_driver {
 /* A Structure for boards to register fixups with the PHY Lib */
 struct phy_fixup {
 	struct list_head list;
-	char bus_id[BUS_ID_SIZE];
+	char bus_id[20];
 	u32 phy_uid;
 	u32 phy_uid_mask;
 	int (*run)(struct phy_device *phydev);
-- 
1.6.3

