From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<ukleinek@informatik.uni-freiburg.de>
Subject: [PATCH] mdiobus_register: check bus not being NULL before dereferencing it.
Date: Wed,  7 Nov 2007 12:31:55 +0100
Message-ID: <1194435115-2596-1-git-send-email-ukleinek@informatik.uni-freiburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?= <Uwe.Kleine-Koenig@digi.com>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlas.informatik.uni-freiburg.de ([132.230.150.3]:32861 "EHLO
	atlas.informatik.uni-freiburg.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbXKGMWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 07:22:50 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Uwe Kleine-K=C3=B6nig <Uwe.Kleine-Koenig@digi.com>
Cc: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/mdio_bus.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fc2f0e6..7ff55bb 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -49,13 +49,13 @@ int mdiobus_register(struct mii_bus *bus)
 	int i;
 	int err =3D 0;
=20
-	spin_lock_init(&bus->mdio_lock);
-
 	if (NULL =3D=3D bus || NULL =3D=3D bus->name ||
 			NULL =3D=3D bus->read ||
 			NULL =3D=3D bus->write)
 		return -EINVAL;
=20
+	spin_lock_init(&bus->mdio_lock);
+
 	if (bus->reset)
 		bus->reset(bus);
=20
--=20
1.5.3.4

