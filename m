From: Peter Meerwald <pmeerw@pmeerw.net>
Subject: [PATCH] improve comments in include/linux/phy.h
Date: Thu, 2 Sep 2010 16:06:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1009021559490.13414@hippogriff.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pitbull.cosy.sbg.ac.at ([141.201.2.122]:49305 "EHLO
	pitbull.cosy.sbg.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab0IBOhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 10:37:55 -0400
Received: from hippogriff.cosy.sbg.ac.at (hippogriff.cosy.sbg.ac.at [141.201.123.218])
	by pitbull.cosy.sbg.ac.at (Postfix) with ESMTP id AF7A220D030
	for <netdev@vger.kernel.org>; Thu,  2 Sep 2010 16:06:27 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


correctly state range of PHY bus addresses (i.e. 0-31) in comment
make spelling of PHY consistent in comments

Signed-off-by: Peter Meerwald <pmeerw@pmeerw.net>
---
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6b0a782..a6e047a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -116,7 +116,7 @@ struct mii_bus {
 	/* list of all PHYs on bus */
 	struct phy_device *phy_map[PHY_MAX_ADDR];
 
-	/* Phy addresses to be ignored when probing */
+	/* PHY addresses to be ignored when probing */
 	u32 phy_mask;
 
 	/*
@@ -283,7 +283,7 @@ struct phy_device {
 
 	phy_interface_t interface;
 
-	/* Bus address of the PHY (0-32) */
+	/* Bus address of the PHY (0-31) */
 	int addr;
 
 	/*

-- 

Peter Meerwald
Kaigasse 3 / 8
A-5020 Salzburg / AUSTRIA
+43-664-2444418 (mobile)
