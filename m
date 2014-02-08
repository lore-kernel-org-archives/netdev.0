From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 02/13] net: Include appropriate header file in caif/caif_dev.c
Date: Sun, 9 Feb 2014 01:19:43 +0530
Message-ID: <30885a464918e0f7cbb55b5c521a048f3e369c27.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include appropriate header file net/caif/caif_dev.h in caif/caif_dev.c
because it has prototype declarations of function defined in
caif/caif_dev.c.

This eliminates the following file in caif/caif_dev.c:
net/caif/caif_dev.c:303:6: warning: no previous prototype for =E2=80=98=
caif_enroll_dev=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/caif/caif_dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 4dca159..edbca46 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -22,6 +22,7 @@
 #include <net/pkt_sched.h>
 #include <net/caif/caif_device.h>
 #include <net/caif/caif_layer.h>
+#include <net/caif/caif_dev.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfcnfg.h>
 #include <net/caif/cfserl.h>
--=20
1.7.9.5
