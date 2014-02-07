From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 26/26] drivers: isdn: Move prototype declaration to header
 file platform.h from divasmain.c
Date: Fri, 7 Feb 2014 18:19:53 +0530
Message-ID: <03ee99107b3f4f0683055b6d0f0a0a6d53801dca.1390408520.git.rashika.kheria@gmail.com>
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

This elliminates the following warnings in hardware/eicon/divasproc.c:
drivers/isdn/hardware/eicon/divasproc.c:125:5: warning: no previous pro=
totype for =E2=80=98create_divas_proc=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/divasproc.c:135:6: warning: no previous pro=
totype for =E2=80=98remove_divas_proc=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/divasmain.c |    3 ---
 drivers/isdn/hardware/eicon/platform.h  |    2 ++
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/har=
dware/eicon/divasmain.c
index 6b15670..3b1e5bc 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -55,9 +55,6 @@ static char *DRIVERLNAME =3D "divas";
 static char *DEVNAME =3D "Divas";
 char *DRIVERRELEASE_DIVAS =3D "2.0";
=20
-extern int create_divas_proc(void);
-extern void remove_divas_proc(void);
-
 typedef struct _diva_os_thread_dpc {
 	struct tasklet_struct divas_task;
 	diva_os_soft_isr_t *psoft_isr;
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index 6bec7db..800b8bd 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -161,6 +161,8 @@ void diva_xdi_didd_remove_adapter(int card);
 void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf);
 int divasfunc_init(int dbgmask);
 void divasfunc_exit(void);
+int create_divas_proc(void);
+void remove_divas_proc(void);
=20
 /*
 ** memory allocation
--=20
1.7.9.5
