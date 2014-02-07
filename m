From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 03/26] drivers: isdn: Move prototype declarations to header
 file um_idi.h from idifunc.c
Date: Fri, 7 Feb 2014 17:50:18 +0530
Message-ID: <9690fa7234af4562d710b03a3ad88d7ab2894a17.1390408514.git.rashika.kheria@gmail.com>
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
hardware/eicon/um_idi.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/divasi.c:
drivers/isdn/hardware/eicon/divasi.c:446:6: warning: no previous protot=
ype for =E2=80=98diva_os_wakeup_read=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/divasi.c:453:6: warning: no previous protot=
ype for =E2=80=98diva_os_wakeup_close=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/idifunc.c |    2 --
 drivers/isdn/hardware/eicon/um_idi.h  |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/idifunc.c b/drivers/isdn/hardw=
are/eicon/idifunc.c
index fef6586..bacab74 100644
--- a/drivers/isdn/hardware/eicon/idifunc.c
+++ b/drivers/isdn/hardware/eicon/idifunc.c
@@ -22,8 +22,6 @@
 extern char *DRIVERRELEASE_IDI;
=20
 extern void DIVA_DIDD_Read(void *, int);
-extern int diva_user_mode_idi_create_adapter(const DESCRIPTOR *, int);
-extern void diva_user_mode_idi_remove_adapter(int);
=20
 static dword notify_handle;
 static DESCRIPTOR DAdapter;
diff --git a/drivers/isdn/hardware/eicon/um_idi.h b/drivers/isdn/hardwa=
re/eicon/um_idi.h
index 00ca1e7..e973809 100644
--- a/drivers/isdn/hardware/eicon/um_idi.h
+++ b/drivers/isdn/hardware/eicon/um_idi.h
@@ -41,5 +41,7 @@ int divas_um_idi_entity_start_remove(void *entity);
=20
 void diva_um_idi_start_wdog(void *entity);
 void diva_um_idi_stop_wdog(void *entity);
+void diva_user_mode_idi_remove_adapter(int);
+int diva_user_mode_idi_create_adapter(const DESCRIPTOR *, int);
=20
 #endif
--=20
1.7.9.5
