From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -next] net/codel: Add missing #include <linux/prefetch.h>
Date: Mon, 14 May 2012 21:47:05 +0200
Message-ID: <1337024825-20130-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Eric Dumazet <edumazet@google.com>,
	Dave Taht <dave.taht@bufferbloat.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

m68k allmodconfig:

net/sched/sch_codel.c: In function =E2=80=98dequeue=E2=80=99:
net/sched/sch_codel.c:70: error: implicit declaration of function =E2=80=
=98prefetch=E2=80=99
make[1]: *** [net/sched/sch_codel.o] Error 1

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
http://kisskb.ellerman.id.au/kisskb/buildresult/6320394/

 net/sched/sch_codel.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index b4a1a81..213ef60 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -46,6 +46,7 @@
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
+#include <linux/prefetch.h>
 #include <net/pkt_sched.h>
 #include <net/codel.h>
=20
--=20
1.7.0.4
