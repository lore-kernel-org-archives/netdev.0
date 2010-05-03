From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6.34-rc5] drivers/net/phy: micrel phy driver
Date: Mon, 03 May 2010 15:49:09 -0700 (PDT)
Message-ID: <20100503.154909.107135972.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D02129E@MELANITE.micrel.com>
	<20100503.154415.160071433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757150Ab0ECWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:49:03 -0400
In-Reply-To: <20100503.154415.160071433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 03 May 2010 15:44:15 -0700 (PDT)

> From: "Choi, David" <David.Choi@Micrel.Com>
> Date: Thu, 29 Apr 2010 09:12:41 -0700
> 
>> To whom it may have concerned:
>> 
>> From: David J. Choi <david.choi@micrel.com>
>> Body of the explanation: This is the first version of phy driver from Micrel Inc.
>> Signed-off-by: David J. Choi <david.choi@micrel.com>
> 
> Applied, thank you.

When I merged this into net-next-2.6 from net-2.6, I added the
appropriate module device table to the driver.

phy/micrel: Add module device ID table for autoloading.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/micrel.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 0cd80e4..68dd107 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -102,3 +102,12 @@ module_exit(ksphy_exit);
 MODULE_DESCRIPTION("Micrel PHY driver");
 MODULE_AUTHOR("David J. Choi");
 MODULE_LICENSE("GPL");
+
+static struct mdio_device_id micrel_tbl[] = {
+	{ PHY_ID_KSZ9021, 0x000fff10 },
+	{ PHY_ID_VSC8201, 0x00fffff0 },
+	{ PHY_ID_KS8001, 0x00fffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, micrel_tbl);
-- 
1.7.0.4

