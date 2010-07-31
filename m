From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 07/29] LMC: Convert media structs to named initializers.
Date: Sat, 31 Jul 2010 17:05:30 +0200
Message-ID: <1280588752-9340-7-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38162 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756473Ab0GaPGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:12 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/media.c |   96 +++++++++++++++++++++--------------=
-------
 1 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 8e236b0..36b685f 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -85,63 +85,63 @@ static inline void write_av9110_bit(struct card *, =
int);
 static void write_av9110(struct card *, u32, u32, u32, u32, u32);
=20
 struct media lmc_ds3_media =3D {
-	lmc_ds3_init,		/* special media init stuff */
-	lmc_ds3_default,	/* reset to default state */
-	lmc_ds3_set_status,	/* reset status to state provided */
-	lmc_dummy_set_1,	/* set clock source */
-	lmc_dummy_set2_1,	/* set line speed */
-	lmc_ds3_set_100ft,	/* set cable length */
-	lmc_ds3_set_scram,	/* set scrambler */
-	lmc_ds3_get_link_status, /* get link status */
-	lmc_dummy_set_1,	/* set link status */
-	lmc_ds3_set_crc_length,	/* set CRC length */
-	lmc_dummy_set_1,	/* set T1 or E1 circuit type */
-	lmc_ds3_watchdog
+	.init =3D lmc_ds3_init,
+	.defaults =3D lmc_ds3_default,
+	.set_status =3D lmc_ds3_set_status,
+	.set_clock_source =3D lmc_dummy_set_1,
+	.set_speed =3D lmc_dummy_set2_1,
+	.set_cable_length =3D lmc_ds3_set_100ft,
+	.set_scrambler =3D lmc_ds3_set_scram,
+	.get_link_status =3D lmc_ds3_get_link_status,
+	.set_link_status =3D lmc_dummy_set_1,
+	.set_crc_length =3D lmc_ds3_set_crc_length,
+	.set_circuit_type =3D lmc_dummy_set_1,
+	.watchdog =3D lmc_ds3_watchdog,
 };
=20
 struct media lmc_hssi_media =3D {
-	lmc_hssi_init,		/* special media init stuff */
-	lmc_hssi_default,	/* reset to default state */
-	lmc_hssi_set_status,	/* reset status to state provided */
-	lmc_hssi_set_clock,	/* set clock source */
-	lmc_dummy_set2_1,	/* set line speed */
-	lmc_dummy_set_1,	/* set cable length */
-	lmc_dummy_set_1,	/* set scrambler */
-	lmc_hssi_get_link_status, /* get link status */
-	lmc_hssi_set_link_status, /* set link status */
-	lmc_hssi_set_crc_length, /* set CRC length */
-	lmc_dummy_set_1,	/* set T1 or E1 circuit type */
-	lmc_hssi_watchdog
+	.init =3D lmc_hssi_init,
+	.defaults =3D lmc_hssi_default,
+	.set_status =3D lmc_hssi_set_status,
+	.set_clock_source =3D lmc_hssi_set_clock,
+	.set_speed =3D lmc_dummy_set2_1,
+	.set_cable_length =3D lmc_dummy_set_1,
+	.set_scrambler =3D lmc_dummy_set_1,
+	.get_link_status =3D lmc_hssi_get_link_status,
+	.set_link_status =3D lmc_hssi_set_link_status,
+	.set_crc_length =3D lmc_hssi_set_crc_length,
+	.set_circuit_type =3D lmc_dummy_set_1,
+	.watchdog =3D lmc_hssi_watchdog,
 };
=20
 struct media lmc_ssi_media =3D {
-	lmc_ssi_init,		/* special media init stuff */
-	lmc_ssi_default,	/* reset to default state */
-	lmc_ssi_set_status,	/* reset status to state provided */
-	lmc_ssi_set_clock,	/* set clock source */
-	lmc_ssi_set_speed,	/* set line speed */
-	lmc_dummy_set_1,	/* set cable length */
-	lmc_dummy_set_1,	/* set scrambler */
-	lmc_ssi_get_link_status, /* get link status */
-	lmc_ssi_set_link_status, /* set link status */
-	lmc_ssi_set_crc_length,	/* set CRC length */
-	lmc_dummy_set_1,	/* set T1 or E1 circuit type */
-	lmc_ssi_watchdog
+	.init =3D lmc_ssi_init,
+	.defaults =3D lmc_ssi_default,
+	.set_status =3D lmc_ssi_set_status,
+	.set_clock_source =3D lmc_ssi_set_clock,
+	.set_speed =3D lmc_ssi_set_speed,
+	.set_cable_length =3D lmc_dummy_set_1,
+	.set_scrambler =3D lmc_dummy_set_1,
+	.get_link_status =3D lmc_ssi_get_link_status,
+	.set_link_status =3D lmc_ssi_set_link_status,
+	.set_crc_length =3D lmc_ssi_set_crc_length,
+	.set_circuit_type =3D lmc_dummy_set_1,
+	.watchdog =3D lmc_ssi_watchdog,
 };
=20
 struct media lmc_t1_media =3D {
-	lmc_t1_init,		/* special media init stuff */
-	lmc_t1_default,		/* reset to default state */
-	lmc_t1_set_status,	/* reset status to state provided */
-	lmc_t1_set_clock,	/* set clock source */
-	lmc_dummy_set2_1,	/* set line speed */
-	lmc_dummy_set_1,	/* set cable length */
-	lmc_dummy_set_1,	/* set scrambler */
-	lmc_t1_get_link_status,	/* get link status */
-	lmc_dummy_set_1,	/* set link status */
-	lmc_t1_set_crc_length,	/* set CRC length */
-	lmc_t1_set_circuit_type, /* set T1 or E1 circuit type */
-	lmc_t1_watchdog
+	.init =3D lmc_t1_init,
+	.defaults =3D lmc_t1_default,
+	.set_status =3D lmc_t1_set_status,
+	.set_clock_source =3D lmc_t1_set_clock,
+	.set_speed =3D lmc_dummy_set2_1,
+	.set_cable_length =3D lmc_dummy_set_1,
+	.set_scrambler =3D lmc_dummy_set_1,
+	.get_link_status =3D lmc_t1_get_link_status,
+	.set_link_status =3D lmc_dummy_set_1,
+	.set_crc_length =3D lmc_t1_set_crc_length,
+	.set_circuit_type =3D lmc_t1_set_circuit_type,
+	.watchdog =3D lmc_t1_watchdog,
 };
=20
 static void lmc_dummy_set_1(struct card * const sc, int a)
--=20
1.7.1.1

