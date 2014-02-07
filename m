From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 21/26] drivers: isdn: Move prototype declaration to header
 file platform.h from os_4bri.c
Date: Fri, 7 Feb 2014 18:14:29 +0530
Message-ID: <ba35e8744d30d59c93c19452ae0a9af4e428a4ce.1390408518.git.rashika.kheria@gmail.com>
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

Move prototype declaration of functions to header file
hardware/eicon/platform.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/s_4bri.c:
drivers/isdn/hardware/eicon/s_4bri.c:128:6: warning: no previous protot=
ype for =E2=80=98start_qBri_hardware=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/s_4bri.c:275:5: warning: no previous protot=
ype for =E2=80=98qBri_FPGA_download=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/s_4bri.c:487:6: warning: no previous protot=
ype for =E2=80=98prepare_qBri_functions=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/s_4bri.c:496:6: warning: no previous protot=
ype for =E2=80=98prepare_qBri2_functions=E2=80=99 [-Wmissing-prototypes=
]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/os_4bri.c  |    9 ---------
 drivers/isdn/hardware/eicon/platform.h |    5 +++++
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/os_4bri.c b/drivers/isdn/hardw=
are/eicon/os_4bri.c
index 54f7033..287ceee 100644
--- a/drivers/isdn/hardware/eicon/os_4bri.c
+++ b/drivers/isdn/hardware/eicon/os_4bri.c
@@ -23,15 +23,6 @@ static void *diva_xdiLoadFileFile =3D NULL;
 static dword diva_xdiLoadFileLength =3D 0;
=20
 /*
-**  IMPORTS
-*/
-extern void prepare_qBri_functions(PISDN_ADAPTER IoAdapter);
-extern void prepare_qBri2_functions(PISDN_ADAPTER IoAdapter);
-
-extern int qBri_FPGA_download(PISDN_ADAPTER IoAdapter);
-extern void start_qBri_hardware(PISDN_ADAPTER IoAdapter);
-
-/*
 **  LOCALS
 */
 static unsigned long _4bri_bar_length[4] =3D {
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index a507cea..af3d0a6 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -187,6 +187,11 @@ void diddfunc_finit(void);
=20
 void prepare_maestra_functions(PISDN_ADAPTER IoAdapter);
=20
+void start_qBri_hardware(PISDN_ADAPTER IoAdapter);
+void prepare_qBri_functions(PISDN_ADAPTER IoAdapter);
+void prepare_qBri2_functions(PISDN_ADAPTER IoAdapter);
+int qBri_FPGA_download(PISDN_ADAPTER IoAdapter);
+
 /*
 ** use skbuffs for message buffer
 */
--=20
1.7.9.5
