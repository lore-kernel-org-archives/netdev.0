From: hmsjwzb <zhengbowang2015@gmail.com>
Subject: [PATCH] Net: irda: actisys-sir: fixed coding style issue
Date: Sun,  3 Jan 2016 20:57:53 +0800
Message-ID: <1451825873-3248-1-git-send-email-zhengbowang2015@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hmsjwzb <zhengbowang2015@gmail.com>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35753 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbcACM6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 07:58:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fixed trail white space

Signed-off-by: ZhengboWang <zhengbowang2015@gmail.com>
---
 drivers/net/irda/actisys-sir.c | 44 ++++++++++++++++++----------------=
--------
 1 file changed, 19 insertions(+), 25 deletions(-)

diff --git a/drivers/net/irda/actisys-sir.c b/drivers/net/irda/actisys-=
sir.c
index e224b8b..c201361 100644
--- a/drivers/net/irda/actisys-sir.c
+++ b/drivers/net/irda/actisys-sir.c
@@ -1,8 +1,8 @@
 /*********************************************************************
- *               =20
+ *
  * Filename:      actisys.c
  * Version:       1.1
- * Description:   Implementation for the ACTiSYS IR-220L and IR-220L+=20
+ * Description:   Implementation for the ACTiSYS IR-220L and IR-220L+
  *                dongles
  * Status:        Beta.
  * Authors:       Dag Brattli <dagb@cs.uit.no> (initially)
@@ -11,24 +11,23 @@
  * Created at:    Wed Oct 21 20:02:35 1998
  * Modified at:   Sun Oct 27 22:02:13 2002
  * Modified by:   Martin Diehl <mad@mdiehl.de>
- *=20
+ *
  *     Copyright (c) 1998-1999 Dag Brattli, All Rights Reserved.
  *     Copyright (c) 1999 Jean Tourrilhes
  *     Copyright (c) 2002 Martin Diehl
- *     =20
- *     This program is free software; you can redistribute it and/or=20
- *     modify it under the terms of the GNU General Public License as=20
- *     published by the Free Software Foundation; either version 2 of=20
+ *
+ *     This program is free software; you can redistribute it and/or
+ *     modify it under the terms of the GNU General Public License as
+ *     published by the Free Software Foundation; either version 2 of
  *     the License, or (at your option) any later version.
- * =20
+ *
  *     Neither Dag Brattli nor University of Troms=C3=B8 admit liabili=
ty nor
- *     provide warranty for any of this software. This material is=20
+ *     provide warranty for any of this software. This material is
  *     provided "AS-IS" and at no charge.
- *    =20
+ *
  ********************************************************************/
=20
-/*
- * Changelog
+/* Changelog
  *
  * 0.8 -> 0.9999 - Jean
  *	o New initialisation procedure : much safer and correct
@@ -48,8 +47,7 @@
=20
 #include "sir-dev.h"
=20
-/*=20
- * Define the timing of the pulses we send to the dongle (to reset it,=
 and
+/* Define the timing of the pulses we send to the dongle (to reset it,=
 and
  * to toggle speeds). Basically, the limit here is the propagation spe=
ed of
  * the signals through the serial port, the dongle being much faster. =
 Any
  * serial port support 115 kb/s, so we are sure that pulses 8.5 us wid=
e can
@@ -121,7 +119,7 @@ static int actisys_open(struct sir_dev *dev)
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
=20
 	/* Set the speeds we can accept */
-	qos->baud_rate.bits &=3D IR_9600|IR_19200|IR_38400|IR_57600|IR_115200=
;
+	qos->baud_rate.bits &=3D IR_9600 | IR_19200 | IR_38400 | IR_57600 | I=
R_115200;
=20
 	/* Remove support for 38400 if this is not a 220L+ dongle */
 	if (dev->dongle_drv->type =3D=3D IRDA_ACTISYS_DONGLE)
@@ -143,8 +141,7 @@ static int actisys_close(struct sir_dev *dev)
 	return 0;
 }
=20
-/*
- * Function actisys_change_speed (task)
+/* Function actisys_change_speed (task)
  *
  *    Change speed of the ACTiSYS IR-220L and IR-220L+ type IrDA dongl=
es.
  *    To cycle through the available baud rates, pulse RTS low for a f=
ew us.
@@ -169,11 +166,9 @@ static int actisys_change_speed(struct sir_dev *de=
v, unsigned speed)
=20
 	/* dongle was already resetted from irda_request state machine,
 	 * we are in known state (dongle default)
-	 */
-
-	/*=20
+	 *
 	 * Now, we can set the speed requested. Send RTS pulses until we
-         * reach the target speed=20
+	 * reach the target speed
 	 */
 	for (i =3D 0; i < MAX_SPEEDS; i++) {
 		if (speed =3D=3D baud_rates[i]) {
@@ -199,8 +194,7 @@ static int actisys_change_speed(struct sir_dev *dev=
, unsigned speed)
 	return ret;
 }
=20
-/*
- * Function actisys_reset (task)
+/* Function actisys_reset (task)
  *
  *      Reset the Actisys type dongle. Warning, this function must onl=
y be
  *      called with a process context!
@@ -229,14 +223,14 @@ static int actisys_reset(struct sir_dev *dev)
=20
 	/* Go back to normal mode */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
-=09
+
 	dev->speed =3D 9600;	/* That's the default */
=20
 	return 0;
 }
=20
 MODULE_AUTHOR("Dag Brattli <dagb@cs.uit.no> - Jean Tourrilhes <jt@hpl.=
hp.com>");
-MODULE_DESCRIPTION("ACTiSYS IR-220L and IR-220L+ dongle driver");=09
+MODULE_DESCRIPTION("ACTiSYS IR-220L and IR-220L+ dongle driver");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("irda-dongle-2"); /* IRDA_ACTISYS_DONGLE */
 MODULE_ALIAS("irda-dongle-3"); /* IRDA_ACTISYS_PLUS_DONGLE */
--=20
1.9.1
