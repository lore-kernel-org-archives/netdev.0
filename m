From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v2=2002/13=5D=20net=3A=20Include=20appropriate=20header=20file=20in=20caif/caif=5Fdev=2Ec?=
Date: Sun,  9 Feb 2014 19:59:04 +0530
Message-ID: <30885a464918e0f7cbb55b5c521a048f3e369c27.1391955924.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include appropriate header file net/caif/caif_dev.h in caif/caif_dev.c
because it has prototype declarations of function defined in
caif/caif_dev.c.

This eliminates the following file in caif/caif_dev.c:
net/caif/caif_dev.c:303:6: warning: no previous prototype for =E2=80=98=
caif_enroll_dev=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
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
