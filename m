From: shemminger@osdl.org
Subject: [RFT 2/5] sky2: accept flow control
Date: Tue, 05 Sep 2006 15:27:36 -0700
Message-ID: <20060905223001.162940618@localhost.localdomain>
References: <20060905222734.082143263@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19864 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965243AbWIEWgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 18:36:32 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-gmac-pause.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't program the GMAC to reject flow control packets.
This maybe the cause of some of the receive hangs.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.h	2006-09-05 15:17:38.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-09-05 15:18:00.000000000 -0700
@@ -1566,7 +1566,7 @@
 
 	GMR_FS_ANY_ERR	= GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
 			  GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
-		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC | GMR_FS_GOOD_FC |
+		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC |
 			  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 

--
Stephen Hemminger <shemminger@osdl.org>

