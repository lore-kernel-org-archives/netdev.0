From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 29/29] LMC: Report proper card type before the first dev->open().
Date: Sat, 31 Jul 2010 17:05:52 +0200
Message-ID: <1280588752-9340-29-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51759 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756613Ab0GaPG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:27 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

 Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 6635afc..14b60ce 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -777,6 +777,7 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	lmc_gpio_mkinput(sc, 0xff);
 	sc->gpio =3D 0;		/* drive no signals yet */
=20
+	sc->media->init(sc);
 	sc->media->defaults(sc);
=20
 	if (sc->media->set_link_status)
--=20
1.7.1.1

