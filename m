From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 20/26] drivers: isdn: Move prototype declaration to header
 file platform.h from os_bri.c
Date: Fri, 7 Feb 2014 18:13:31 +0530
Message-ID: <12fda898932a31976ad618bfd170ccff77b675ac.1390408518.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of function to header file because they are
used by more than one file.

This eliminates the following warnings in hardware/eicon/s_bri.c:
drivers/isdn/hardware/eicon/s_bri.c:163:6: warning: no previous prototy=
pe for =E2=80=98prepare_maestra_functions=E2=80=99 [-Wmissing-prototype=
s]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/os_bri.c   |    5 -----
 drivers/isdn/hardware/eicon/platform.h |    2 ++
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/os_bri.c b/drivers/isdn/hardwa=
re/eicon/os_bri.c
index c7a45e6..b61e335 100644
--- a/drivers/isdn/hardware/eicon/os_bri.c
+++ b/drivers/isdn/hardware/eicon/os_bri.c
@@ -20,11 +20,6 @@
 #include "diva.h"
=20
 /*
-**  IMPORTS
-*/
-extern void prepare_maestra_functions(PISDN_ADAPTER IoAdapter);
-
-/*
 **  LOCALS
 */
 static int bri_bar_length[3] =3D {
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index d648ab7..a507cea 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -185,6 +185,8 @@ void idifunc_finit(void);
 int diddfunc_init(void);
 void diddfunc_finit(void);
=20
+void prepare_maestra_functions(PISDN_ADAPTER IoAdapter);
+
 /*
 ** use skbuffs for message buffer
 */
--=20
1.7.9.5
