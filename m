From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 20/29] LMC: Remove unused sc->board_idx.
Date: Sat, 31 Jul 2010 17:05:43 +0200
Message-ID: <1280588752-9340-20-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57508 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756553Ab0GaPGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:21 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c |    1 -
 drivers/net/wan/lmc/var.h  |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 56631d4..2229e0a 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -836,7 +836,6 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	/* reset clock */
 	LMC_CSR_WRITE(sc, csr_gp_timer, 0xFFFFFFFFUL);
=20
-	sc->board_idx =3D cards_found++;
 	sc->extra_stats.check =3D STATCHECK;
 	sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
 		sizeof(sc->netdev->stats) + sizeof(sc->extra_stats);
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 10cb70d..729ab9f 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -267,7 +267,6 @@ typedef struct lmc_xinfo {
 /* forward decl */
 struct card {
 	char *name;
-	u8 board_idx;
 	struct lmc_extra_statistics extra_stats;
 	struct net_device *netdev;
=20
--=20
1.7.1.1

