From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 19/26] drivers: isdn: Move prototype declaration to header
 file platform.h from diva_didd.c
Date: Fri, 7 Feb 2014 18:12:30 +0530
Message-ID: <93d7188538418423685ecefaf3d2bb311b37be6e.1390408518.git.rashika.kheria@gmail.com>
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

Move prototype declarations of function to header file
hardware/eicon/platform.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/diddfunc.c:
drivers/isdn/hardware/eicon/diddfunc.c:95:12: warning: no previous prot=
otype for =E2=80=98diddfunc_init=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/diddfunc.c:110:13: warning: no previous pro=
totype for =E2=80=98diddfunc_finit=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/diva_didd.c |    3 ---
 drivers/isdn/hardware/eicon/platform.h  |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/har=
dware/eicon/diva_didd.c
index fab6ccf..56d32a7 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -39,9 +39,6 @@ MODULE_LICENSE("GPL");
 #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
 #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
=20
-extern int diddfunc_init(void);
-extern void diddfunc_finit(void);
-
 extern void DIVA_DIDD_Read(void *, int);
=20
 static struct proc_dir_entry *proc_didd;
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index 33d6be1..d648ab7 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -182,6 +182,9 @@ static __inline__ void diva_os_free(unsigned long f=
lags, void *ptr)
 int idifunc_init(void);
 void idifunc_finit(void);
=20
+int diddfunc_init(void);
+void diddfunc_finit(void);
+
 /*
 ** use skbuffs for message buffer
 */
--=20
1.7.9.5
