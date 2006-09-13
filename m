From: bora.sahin@ttnet.net.tr
Subject: [PATCH 11/12] smc911x: Undocumented interrupt now reserved
Date: Wed, 13 Sep 2006 21:37:39 +0300
Message-ID: <200609132137.39606.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:45949 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751061AbWIMSfW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:35:22 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



In Rev B silicon=20
	#define=A0=A0=A0=A0INT_STS_RXDF_INT_=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0(0x00400000) =A0/* R/WC */
seems reserved.

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000=
000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.62145883=
2 +0300
@@ -1127,7 +1125,7 @@
 			lp->stats.rx_dropped+=3DSMC_GET_RX_DROP();
 		 }
 		/* Undocumented interrupt-what is the right thing to do here? */
-		if (status & INT_STS_RXDF_INT_) {
+		if (IS_REV_A(lp->revision) && status & INT_STS_RXDF_INT_) {
 			SMC_ACK_INT(INT_STS_RXDF_INT_);
 		}
=20
