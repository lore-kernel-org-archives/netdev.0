From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 22/26] drivers: isdn: Move prototype declaration to header
 file platform.h from os_pri.c
Date: Fri, 7 Feb 2014 18:15:25 +0530
Message-ID: <75cbf329199ed91fac870437917e7d14a7e59635.1390408519.git.rashika.kheria@gmail.com>
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

Move prototype declarations of functions to header file because they ar=
e
used by more than file.

This eliminates the following warnings in hardware/eicon/s_pri.c:
drivers/isdn/hardware/eicon/s_pri.c:192:6: warning: no previous prototy=
pe for =E2=80=98prepare_pri_functions=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/eicon/s_pri.c:200:6: warning: no previous prototy=
pe for =E2=80=98prepare_pri2_functions=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/os_pri.c   |    6 ------
 drivers/isdn/hardware/eicon/platform.h |    3 +++
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/os_pri.c b/drivers/isdn/hardwa=
re/eicon/os_pri.c
index acc1de6..129007c 100644
--- a/drivers/isdn/hardware/eicon/os_pri.c
+++ b/drivers/isdn/hardware/eicon/os_pri.c
@@ -30,12 +30,6 @@
 #define DIVA_PRI_NO_PCI_BIOS_WORKAROUND 1
=20
=20
-/*
-**  IMPORTS
-*/
-extern void prepare_pri_functions(PISDN_ADAPTER IoAdapter);
-extern void prepare_pri2_functions(PISDN_ADAPTER IoAdapter);
-
 static int diva_pri_cleanup_adapter(diva_os_xdi_adapter_t *a);
 static int diva_pri_cmd_card_proc(struct _diva_os_xdi_adapter *a,
 				  diva_xdi_um_cfg_cmd_t *cmd, int length);
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index af3d0a6..f26f6cb 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -192,6 +192,9 @@ void prepare_qBri_functions(PISDN_ADAPTER IoAdapter=
);
 void prepare_qBri2_functions(PISDN_ADAPTER IoAdapter);
 int qBri_FPGA_download(PISDN_ADAPTER IoAdapter);
=20
+void prepare_pri_functions(PISDN_ADAPTER IoAdapter);
+void prepare_pri2_functions(PISDN_ADAPTER IoAdapter);
+
 /*
 ** use skbuffs for message buffer
 */
--=20
1.7.9.5
