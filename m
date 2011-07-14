From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 02/10] net: m68k/nfeth: Remove wrong usage of dev->flags
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <4ce98e5d11f271278ef1ddf3e6186f31c7eef2aa.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@lists.linux-m68k.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59812 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab1GNAKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:31 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove wrong setting of dev->flags. NETIF_F_NO_CSUM maps to IFF_DEBUG
there, so looks like a mistake.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 arch/m68k/emu/nfeth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/m68k/emu/nfeth.c b/arch/m68k/emu/nfeth.c
index 3c55312..c5748bb 100644
--- a/arch/m68k/emu/nfeth.c
+++ b/arch/m68k/emu/nfeth.c
@@ -205,7 +205,6 @@ static struct net_device * __init nfeth_probe(int u=
nit)
 	dev->irq =3D nfEtherIRQ;
 	dev->netdev_ops =3D &nfeth_netdev_ops;
=20
-	dev->flags |=3D NETIF_F_NO_CSUM;
 	memcpy(dev->dev_addr, mac, ETH_ALEN);
=20
 	priv =3D netdev_priv(dev);
--=20
1.7.5.4

