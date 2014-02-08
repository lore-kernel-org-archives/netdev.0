From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 03/13] net: Include appropriate header file in caif/cfsrvl.c
Date: Sun, 9 Feb 2014 01:21:51 +0530
Message-ID: <6b6ceef0f79bffec0ec14784dc3d921d53231a3b.1391888654.git.rashika.kheria@gmail.com>
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

Include appropriate header file net/caif/caif_dev.h in caif/cfsrvl.c
because it has prototype declaration of functions defined in
caif/cfsrvl.c.

This eliminates the following warning in caif/cfsrvl.c:
net/caif/cfsrvl.c:198:6: warning: no previous prototype for =E2=80=98ca=
if_free_client=E2=80=99 [-Wmissing-prototypes]
net/caif/cfsrvl.c:208:6: warning: no previous prototype for =E2=80=98ca=
if_client_register_refcnt=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/caif/cfsrvl.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 353f793..a6e1154 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -15,6 +15,7 @@
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfsrvl.h>
 #include <net/caif/cfpkt.h>
+#include <net/caif/caif_dev.h>
=20
 #define SRVL_CTRL_PKT_SIZE 1
 #define SRVL_FLOW_OFF 0x81
--=20
1.7.9.5
