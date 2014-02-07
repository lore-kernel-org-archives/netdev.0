From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 09/26] drivers: isdn: Include appropriate header file in
 diva.c
Date: Fri, 7 Feb 2014 17:58:32 +0530
Message-ID: <d1f2a6a9c34f0e96cd2d24cd240f334a48864cff.1390408516.git.rashika.kheria@gmail.com>
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

Include appropriate header file helpers.h in hardware/eicon/diva.c
because it defines function declared in the header file.

This eliminates the following warning in hardware/eicon/diva.c:
drivers/isdn/hardware/eicon/diva.c:655:6: warning: no previous prototyp=
e for =E2=80=98xdiFreeFile=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/diva.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/isdn/hardware/eicon/diva.c b/drivers/isdn/hardware=
/eicon/diva.c
index d91dd58..6f28797 100644
--- a/drivers/isdn/hardware/eicon/diva.c
+++ b/drivers/isdn/hardware/eicon/diva.c
@@ -17,6 +17,7 @@
 #include "xdi_adapter.h"
 #include "diva_pci.h"
 #include "diva.h"
+#include "helpers.h"
=20
 #ifdef CONFIG_ISDN_DIVAS_PRIPCI
 #include "os_pri.h"
--=20
1.7.9.5
