From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 16/26] drivers: isdn: Move prototype declarations to
 appropriate header file hscx.h from elsa_ser.c
Date: Fri, 7 Feb 2014 18:08:23 +0530
Message-ID: <e32c0193b53196909f461a3f54cd8c196619b696.1390408517.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declarations of functions to header file hisax/hscx.h
because they are used by more than one file.

This eliminates the following warnings in hisax/hscx.c:
drivers/isdn/hisax/hscx.c:96:1: warning: no previous prototype for =E2=80=
=98hscx_l2l1=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/hscx.c:175:1: warning: no previous prototype for =E2=
=80=98open_hscxstate=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hisax/elsa_ser.c |    2 --
 drivers/isdn/hisax/hscx.h     |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/elsa_ser.c b/drivers/isdn/hisax/elsa_se=
r.c
index 3f84dd8..0d5ccd2 100644
--- a/drivers/isdn/hisax/elsa_ser.c
+++ b/drivers/isdn/hisax/elsa_ser.c
@@ -419,9 +419,7 @@ static void rs_interrupt_elsa(struct IsdnCardState =
*cs)
 #endif
 }
=20
-extern int open_hscxstate(struct IsdnCardState *cs, struct BCState *bc=
s);
 extern void modehscx(struct BCState *bcs, int mode, int bc);
-extern void hscx_l2l1(struct PStack *st, int pr, void *arg);
=20
 static void
 close_elsastate(struct BCState *bcs)
diff --git a/drivers/isdn/hisax/hscx.h b/drivers/isdn/hisax/hscx.h
index 1148b4b..e99db24 100644
--- a/drivers/isdn/hisax/hscx.h
+++ b/drivers/isdn/hisax/hscx.h
@@ -39,3 +39,5 @@ extern void modehscx(struct BCState *bcs, int mode, i=
nt bc);
 extern void clear_pending_hscx_ints(struct IsdnCardState *cs);
 extern void inithscx(struct IsdnCardState *cs);
 extern void inithscxisac(struct IsdnCardState *cs, int part);
+extern void hscx_l2l1(struct PStack *st, int pr, void *arg);
+extern int open_hscxstate(struct IsdnCardState *cs, struct BCState *bc=
s);
--=20
1.7.9.5
