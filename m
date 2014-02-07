From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 17/26] drivers: isdn: Move prototype declaration to header
 file platform.h from divasi.c
Date: Fri, 7 Feb 2014 18:09:28 +0530
Message-ID: <315fb0ac18a0c05a74bca047f3e12bbd35a495b7.1390408518.git.rashika.kheria@gmail.com>
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

Move prototype declarations of functions to header file
hardware/eicon/platform.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/idifunc.c:
drivers/isdn/hardware/eicon/idifunc.c:243:12: warning: no previous prot=
otype for =E2=80=98idifunc_init=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/idifunc.c:263:13: warning: no previous prot=
otype for =E2=80=98idifunc_finit=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/divasi.c   |    3 ---
 drivers/isdn/hardware/eicon/platform.h |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasi.c b/drivers/isdn/hardwa=
re/eicon/divasi.c
index 4103a8c..c2a6f1a 100644
--- a/drivers/isdn/hardware/eicon/divasi.c
+++ b/drivers/isdn/hardware/eicon/divasi.c
@@ -48,9 +48,6 @@ static char *DRIVERLNAME =3D "diva_idi";
 static char *DEVNAME =3D "DivasIDI";
 char *DRIVERRELEASE_IDI =3D "2.0";
=20
-extern int idifunc_init(void);
-extern void idifunc_finit(void);
-
 /*
  *  helper functions
  */
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index f170e21..33d6be1 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -179,6 +179,9 @@ static __inline__ void diva_os_free(unsigned long f=
lags, void *ptr)
 	vfree(ptr);
 }
=20
+int idifunc_init(void);
+void idifunc_finit(void);
+
 /*
 ** use skbuffs for message buffer
 */
--=20
1.7.9.5
