From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN/LMC: Fix type_trans().
Date: Thu, 20 Aug 2009 11:56:20 +0200
Message-ID: <m37hwyerln.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51944 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411AbZHTJ4U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:56:20 -0400
Received: from intrepid.localdomain (intrepid.localdomain [10.0.0.2])
	by khc.piap.pl (Postfix) with ESMTP id F30D7934E
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 11:56:20 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix lmc_proto_type() invocation.

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_m=
ain.c
index 45b1822..1b46d56 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1657,7 +1657,7 @@ static int lmc_rx(struct net_device *dev)
             }
             skb_copy_from_linear_data(skb, skb_put(nsb, len), len);
            =20
-            nsb->protocol =3D lmc_proto_type(sc, skb);
+            nsb->protocol =3D lmc_proto_type(sc, nsb);
             skb_reset_mac_header(nsb);
             /* skb_reset_network_header(nsb); */
             nsb->dev =3D dev;

--=20
Krzysztof Halasa
