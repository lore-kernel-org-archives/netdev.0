From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 23/26] drivers: isdn: Move prototype declaration to header
 file platform.h from divamnt.c
Date: Fri, 7 Feb 2014 18:16:34 +0530
Message-ID: <be2e88206b9ca92090b57eb2981dfe606b0c824b.1390408519.git.rashika.kheria@gmail.com>
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

This eliminates the following warnings in hardware/eicon/mntfunc.c:
drivers/isdn/hardware/eicon/mntfunc.c:136:5: warning: no previous proto=
type for =E2=80=98maint_read_write=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/mntfunc.c:303:12: warning: no previous prot=
otype for =E2=80=98mntfunc_init=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/mntfunc.c:351:13: warning: no previous prot=
otype for =E2=80=98mntfunc_finit=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/divamnt.c  |    4 ----
 drivers/isdn/hardware/eicon/platform.h |    4 ++++
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divamnt.c b/drivers/isdn/hardw=
are/eicon/divamnt.c
index 48db08d..02a1d0d 100644
--- a/drivers/isdn/hardware/eicon/divamnt.c
+++ b/drivers/isdn/hardware/eicon/divamnt.c
@@ -47,10 +47,6 @@ static wait_queue_head_t msgwaitq;
 static unsigned long opened;
 static struct timeval start_time;
=20
-extern int mntfunc_init(int *, void **, unsigned long);
-extern void mntfunc_finit(void);
-extern int maint_read_write(void __user *buf, int count);
-
 /*
  *  helper functions
  */
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index f26f6cb..6bec7db 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -195,6 +195,10 @@ int qBri_FPGA_download(PISDN_ADAPTER IoAdapter);
 void prepare_pri_functions(PISDN_ADAPTER IoAdapter);
 void prepare_pri2_functions(PISDN_ADAPTER IoAdapter);
=20
+int mntfunc_init(int *, void **, unsigned long);
+void mntfunc_finit(void);
+int maint_read_write(void __user *buf, int count);
+
 /*
 ** use skbuffs for message buffer
 */
--=20
1.7.9.5
