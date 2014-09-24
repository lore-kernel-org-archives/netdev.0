From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 02/24] net: rbridge: Add layer 2 IS-IS Ethertype
Date: Wed, 24 Sep 2014 17:51:58 +0200
Message-ID: <1411573940-14079-3-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:52137 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792AbaIXP6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:12 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>

Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
Signed-off-by: William Dauchy <william@gandi.net>
Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
---
 include/uapi/linux/if_ether.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ethe=
r.h
index a9eb2f2..5cc2de6 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -49,6 +49,7 @@
 #define ETH_P_IEEEPUP	0x0a00		/* Xerox IEEE802.3 PUP packet */
 #define ETH_P_IEEEPUPAT	0x0a01		/* Xerox IEEE802.3 PUP Addr Trans pack=
et */
 #define ETH_P_TRILL	0x22F3		/* TRILL frames RFC 6325 */
+#define ETH_P_L2_ISIS	0x22F4		/* L2-IS-IS frames RFC 6325 */
 #define ETH_P_BATMAN	0x4305		/* B.A.T.M.A.N.-Advanced packet [ NOT AN =
OFFICIALLY REGISTERED ID ] */
 #define ETH_P_DEC       0x6000          /* DEC Assigned proto         =
  */
 #define ETH_P_DNA_DL    0x6001          /* DEC DNA Dump/Load          =
  */
--=20
1.9.1
