From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/6] sky2: accept flow control
Date: Wed, 06 Sep 2006 10:17:53 -0700
Message-ID: <20060906171920.479727000@localhost.localdomain>
References: <20060906171752.781595000@localhost.localdomain>
Cc: stable@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13735 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751246AbWIFSJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:09:41 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-pause-fixes.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't program the GMAC to reject flow control packets.
This maybe the cause of some of the transmit hangs.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.17.11.orig/drivers/net/sky2.h	2006-09-06 10:02:11.000000000 -0700
+++ linux-2.6.17.11/drivers/net/sky2.h	2006-09-06 10:08:59.000000000 -0700
@@ -1566,7 +1566,7 @@
 
 	GMR_FS_ANY_ERR	= GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
 			  GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
-		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC | GMR_FS_GOOD_FC |
+		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC |
 			  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 

--
Stephen Hemminger <shemminger@osdl.org>

