From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] isdn/sc: Fix incorrect module_param_array types
Date: Wed, 24 Apr 2013 14:46:37 +0200
Message-ID: <1366807597-24314-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Karsten Keil <isdn@linux-pingi.de>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/isdn/sc/init.c: In function =E2=80=98__check_irq=E2=80=99:
drivers/isdn/sc/init.c:36: warning: return from incompatible pointer ty=
pe
drivers/isdn/sc/init.c: In function =E2=80=98__check_ram=E2=80=99:
drivers/isdn/sc/init.c:37: warning: return from incompatible pointer ty=
pe

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/isdn/sc/init.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/sc/init.c b/drivers/isdn/sc/init.c
index 6b580b2..ca997bd 100644
--- a/drivers/isdn/sc/init.c
+++ b/drivers/isdn/sc/init.c
@@ -33,8 +33,8 @@ static unsigned long ram[] =3D {0, 0, 0, 0};
 static bool do_reset =3D 0;
=20
 module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
-module_param_array(ram, int, NULL, 0);
+module_param_array(irq, byte, NULL, 0);
+module_param_array(ram, long, NULL, 0);
 module_param(do_reset, bool, 0);
=20
 static int identify_board(unsigned long, unsigned int);
--=20
1.7.0.4
