From: Jens Osterkamp <jens@de.ibm.com>
Subject: spidernet: replace whitespaces by tabs
Date: Wed, 24 May 2006 23:33:11 +0200
Message-ID: <200605242333.11308.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, utz.bacher@de.ibm.com, maxim@de.ibm.com,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:54874 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP id S932763AbWEXVdP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 17:33:15 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k4OLXDg0155830
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 21:33:13 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4OLYFes142462
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 22:34:15 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4OLXCRa029734
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 22:33:13 +0100
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>

The original patch was using whitespaces instead of tabs.

Signed-off-by: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

Index: linux-2.6.17-rc4/drivers/net/sungem_phy.c
===================================================================
--- linux-2.6.17-rc4.orig/drivers/net/sungem_phy.c
+++ linux-2.6.17-rc4/drivers/net/sungem_phy.c
@@ -345,9 +345,9 @@ static int bcm5421_enable_fiber(struct m
 
 static int bcm5461_enable_fiber(struct mii_phy* phy)
 {
-        phy_write(phy, MII_NCONFIG, 0xfc0c);
-        phy_write(phy, MII_BMCR, 0x4140);
-        phy_write(phy, MII_NCONFIG, 0xfc0b);
+	phy_write(phy, MII_NCONFIG, 0xfc0c);
+	phy_write(phy, MII_BMCR, 0x4140);
+	phy_write(phy, MII_NCONFIG, 0xfc0b);
 	phy_write(phy, MII_BMCR, 0x0140);
 
 	return 0;
