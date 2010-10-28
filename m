From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: atarilance - flags should be unsigned long
Date: Thu, 28 Oct 2010 20:31:53 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1010282030530.29788@ayla.of.borg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	Linux/m68k <linux-m68k@lists.linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/atarilance.c: In function =A1addr_accessible=A2:
drivers/net/atarilance.c:413: warning: comparison of distinct pointer t=
ypes lacks a cast
drivers/net/atarilance.c:450: warning: comparison of distinct pointer t=
ypes lacks a cast

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/atarilance.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 3134e53..8cb27cb 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -407,7 +407,7 @@ static noinline int __init addr_accessible(volatile=
 void *regp, int wordflag,
 					   int writeflag)
 {
 	int		ret;
-	long	flags;
+	unsigned long	flags;
 	long	*vbr, save_berr;
=20
 	local_irq_save(flags);
--=20
1.7.0.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
							    -- Linus Torvalds
