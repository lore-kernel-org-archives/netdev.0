From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] wiznet: Add missing #include <linux/irq.h>
Date: Thu, 12 Apr 2012 21:19:23 +0200
Message-ID: <1334258363-17617-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:52307 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab2DLTTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 15:19:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

m68k/allmodconfig:

drivers/net/ethernet/wiznet/w5100.c: In function =E2=80=98w5100_hw_prob=
e=E2=80=99:
drivers/net/ethernet/wiznet/w5100.c:680: error: =E2=80=98IRQ_TYPE_LEVEL=
_LOW=E2=80=99 undeclared (first use in this function)
drivers/net/ethernet/wiznet/w5300.c: In function =E2=80=98w5300_hw_prob=
e=E2=80=99:
drivers/net/ethernet/wiznet/w5300.c:594: error: =E2=80=98IRQ_TYPE_LEVEL=
_LOW=E2=80=99 undeclared (first use in this function)

Include <linux/irq.h>, which provides the declaration for IRQ_TYPE_LEVE=
L_LOW.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
--
Or should these drivers use IRQF_TRIGGER_LOW (from <linux/interrupt.h>)
instead?

http://kisskb.ellerman.id.au/kisskb/buildresult/6095757/
---
 drivers/net/ethernet/wiznet/w5100.c |    1 +
 drivers/net/ethernet/wiznet/w5300.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet=
/wiznet/w5100.c
index c28e1d5..ecc6820 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -24,6 +24,7 @@
 #include <linux/io.h>
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
+#include <linux/irq.h>
 #include <linux/gpio.h>
=20
 #define DRV_NAME	"w5100"
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet=
/wiznet/w5300.c
index 88afde9..0a20797 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -25,6 +25,7 @@
 #include <linux/io.h>
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
+#include <linux/irq.h>
 #include <linux/gpio.h>
=20
 #define DRV_NAME	"w5300"
--=20
1.7.0.4
