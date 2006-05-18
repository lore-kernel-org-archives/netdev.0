From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 06/10] [RFT] bcm43xx: fix bcm43xx_wireless_core_mark_inactive
Date: Fri, 19 May 2006 00:00:06 +0200
Message-ID: <20060519155716.595099000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:56445 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932372AbWESP5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:57:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-80211core_inactive.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial change in specs related to bcm43xx_wireless_core_mark_inactive.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1431,7 +1431,6 @@ static int bcm43xx_wireless_core_mark_in
 		if (err)
 			goto out;
 		sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-		sbtmstatelow &= ~0x20000000;
 		sbtmstatelow |= 0x20000000;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
 		err = bcm43xx_switch_core(bcm, old_core);

--
Ciao
Stefano
