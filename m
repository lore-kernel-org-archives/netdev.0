From: =?UTF-8?q?Ville=20Skytt=C3=A4?= <ville.skytta@iki.fi>
Subject: [PATCH] Spelling fixes.
Date: Sun, 15 Dec 2013 14:19:31 +0200
Message-ID: <1387109971-6048-1-git-send-email-ville.skytta@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from filtteri1.pp.htv.fi ([213.243.153.184]:40914 "EHLO
	filtteri1.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab3LOMTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 07:19:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ville Skytt=C3=A4 <ville.skytta@iki.fi>
---
 ChangeLog | 4 ++--
 NEWS      | 2 +-
 e1000.c   | 2 +-
 ethtool.c | 2 +-
 natsemi.c | 6 +++---
 sfpdiag.c | 4 ++--
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/ChangeLog b/ChangeLog
index 1fd043e..3efc75b 100644
--- a/ChangeLog
+++ b/ChangeLog
@@ -95,7 +95,7 @@ Thu Jan 16 2003   Jeb Cramer  <jeb.j.cramer@intel.com=
>
=20
 	* ethtool.c (do_regs, dump_eeprom): Fix memory leaks on failed
 	operations.  Add error handling of dump_regs().  Modify printout of
-	eeprom dump to accomodate larger eeproms.
+	eeprom dump to accommodate larger eeproms.
 	* e1000.c: Update supported devices.  Add error conditions for
 	unsupported devices.
=20
@@ -190,7 +190,7 @@ Wed May 1 2002  Eli Kupermann  <eli.kupermann@intel=
=2Ecom>
=20
 Wed May 1 2002  Christoph Hellwig  <hch@lst.de>
=20
-	* Makefile.am (dist-hook): Use $(top-srcdir) for refering to sources.
+	* Makefile.am (dist-hook): Use $(top-srcdir) for referring to sources=
=2E
=20
 Mon Apr 29 2002  Christoph Hellwig  <hch@lst.de>
=20
diff --git a/NEWS b/NEWS
index ddf43ab..2182880 100644
--- a/NEWS
+++ b/NEWS
@@ -180,7 +180,7 @@ Version 2.6.35 - August 10, 2010
 Version 2.6.34 - May 26, 2010
=20
 	* Feature: Support n-tuple filter programming
-	* Feature: Support rx hashing, v2 (targetted for 2.6.35)
+	* Feature: Support rx hashing, v2 (targeted for 2.6.35)
 	* Feature: Add names of newer Marvell chips
=20
 Version 2.6.33 - February 24, 2010
diff --git a/e1000.c b/e1000.c
index dd47774..afeb7f8 100644
--- a/e1000.c
+++ b/e1000.c
@@ -608,7 +608,7 @@ e1000_dump_regs(struct ethtool_drvinfo *info, struc=
t ethtool_regs *regs)
 		reg =3D regs_buff[17];
 		fprintf(stdout,
 			"M88 PHY CONTROL REGISTER:                0x%08X\n"
-			"      Jabber funtion:                    %s\n"
+			"      Jabber function:                   %s\n"
 			"      Auto-polarity:                     %s\n"
 			"      SQE Test:                          %s\n"
 			"      CLK125:                            %s\n"
diff --git a/ethtool.c b/ethtool.c
index b06dfa3..315d00f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3326,7 +3326,7 @@ static int do_srxntuple(struct cmd_context *ctx,
 	err =3D send_ioctl(ctx, &ntuplecmd);
=20
 	/*
-	 * Display error only if reponse is something other than op not
+	 * Display error only if response is something other than op not
 	 * supported.  It is possible that the interface uses the network
 	 * flow classifier interface instead of N-tuple.=20
 	 */=20
diff --git a/natsemi.c b/natsemi.c
index eaf83e2..ac29be5 100644
--- a/natsemi.c
+++ b/natsemi.c
@@ -437,8 +437,8 @@ natsemi_dump_regs(struct ethtool_drvinfo *info, str=
uct ethtool_regs *regs)
 		data[REG_TXCFG]);
 	tmp =3D (data[REG_TXCFG] & BIT_TXCFG_MXDMA)>>20;
 	fprintf(stdout,
-		"      Drain Threshhold =3D %d bytes (%d)\n"
-		"      Fill Threshhold =3D %d bytes (%d)\n"
+		"      Drain Threshold =3D %d bytes (%d)\n"
+		"      Fill Threshold =3D %d bytes (%d)\n"
 		"      Max DMA Burst per Tx =3D %d bytes\n"
 		"      Automatic Tx Padding %s\n"
 		"      Mac Loopback %s\n"
@@ -466,7 +466,7 @@ natsemi_dump_regs(struct ethtool_drvinfo *info, str=
uct ethtool_regs *regs)
 		data[REG_RXCFG]);
 	tmp =3D (data[REG_RXCFG] & BIT_RXCFG_MXDMA)>>20;
 	fprintf(stdout,
-		"      Drain Threshhold =3D %d bytes (%d)\n"
+		"      Drain Threshold =3D %d bytes (%d)\n"
 		"      Max DMA Burst per Rx =3D %d bytes\n"
 		"      Long Packets %s\n"
 		"      Tx Packets %s\n"
diff --git a/sfpdiag.c b/sfpdiag.c
index 04fd880..812a2fa 100644
--- a/sfpdiag.c
+++ b/sfpdiag.c
@@ -103,14 +103,14 @@ struct sff8472_diags {
 	__u16 tx_power[5];      /* Measured TX Power in 0.1uW units */
 	__u16 rx_power[5];      /* Measured RX Power */
 	__u8  rx_power_type;    /* 0 =3D OMA, 1 =3D Average power */
-	__s16 sfp_temp[5];      /* SFP Temp in 16-bit signed 1/256 Celcius */
+	__s16 sfp_temp[5];      /* SFP Temp in 16-bit signed 1/256 Celsius */
 	__u16 sfp_voltage[5];   /* SFP voltage in 0.1mV units */
=20
 };
=20
 static struct sff8472_aw_flags {
 	const char *str;        /* Human-readable string, null at the end */
-	int offset;             /* A2-relative adress offset */
+	int offset;             /* A2-relative address offset */
 	__u8 value;             /* Alarm is on if (offset & value) !=3D 0. */
 } sff8472_aw_flags[] =3D {
 	{ "Laser bias current high alarm",   SFF_A2_ALRM_FLG, (1 << 3) },
--=20
1.8.3.1
