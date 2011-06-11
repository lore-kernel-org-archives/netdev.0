From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -next] net/m68k: Include <linux/interrupt.h> where needed
Date: Sat, 11 Jun 2011 13:38:55 +0200
Message-ID: <1307792335-9926-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

arch/m68k/emu/nfeth.c: In function =E2=80=98nfeth_init=E2=80=99:
arch/m68k/emu/nfeth.c:243: error: implicit declaration of function =E2=80=
=98request_irq=E2=80=99
arch/m68k/emu/nfeth.c:243: error: =E2=80=98IRQF_SHARED=E2=80=99 undecla=
red (first use in this function)
arch/m68k/emu/nfeth.c:243: error: (Each undeclared identifier is report=
ed only once
arch/m68k/emu/nfeth.c:243: error: for each function it appears in.)
arch/m68k/emu/nfeth.c: In function =E2=80=98nfeth_cleanup=E2=80=99:
arch/m68k/emu/nfeth.c:266: error: implicit declaration of function =E2=80=
=98free_irq=E2=80=99
drivers/net/apne.c: In function =E2=80=98apne_probe=E2=80=99:
drivers/net/apne.c:189: error: implicit declaration of function =E2=80=98=
free_irq=E2=80=99
drivers/net/apne.c: In function =E2=80=98apne_probe1=E2=80=99:
drivers/net/apne.c:317: error: implicit declaration of function =E2=80=98=
request_irq=E2=80=99
drivers/net/apne.c:317: error: =E2=80=98IRQF_SHARED=E2=80=99 undeclared=
 (first use in this function)
drivers/net/apne.c:317: error: (Each undeclared identifier is reported =
only once
drivers/net/apne.c:317: error: for each function it appears in.)

Introduced by commit a6b7a407865a ("net: remove interrupt.h inclusion f=
rom
netdevice.h").

Include <linux/interrupt.h> in the individual drivers to fix the build.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/m68k/emu/nfeth.c |    1 +
 drivers/net/apne.c    |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/m68k/emu/nfeth.c b/arch/m68k/emu/nfeth.c
index 8b6e201..3c55312 100644
--- a/arch/m68k/emu/nfeth.c
+++ b/arch/m68k/emu/nfeth.c
@@ -16,6 +16,7 @@
=20
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <asm/natfeat.h>
 #include <asm/virtconvert.h>
diff --git a/drivers/net/apne.c b/drivers/net/apne.c
index 2fe60f1..5477373 100644
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -36,6 +36,7 @@
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/interrupt.h>
 #include <linux/jiffies.h>
=20
 #include <asm/system.h>
--=20
1.7.0.4
