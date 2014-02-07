From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 13/26] drivers: isdn: Mark functions as static in avmfritz.c
Date: Fri, 7 Feb 2014 18:05:19 +0530
Message-ID: <3215b0668fa427737d7850d6ee9e7c67075983d5.1390408517.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark functions as static in hardware/mISDN/avmfritz.c because they are
not used outside this file.

This eliminates the following warnings in hardware/mISDN/avmfritz.c:
drivers/isdn/hardware/mISDN/avmfritz.c:288:1: warning: no previous prot=
otype for =E2=80=98write_ctrl=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/avmfritz.c:745:1: warning: no previous prot=
otype for =E2=80=98clear_pending_hdlc_ints=E2=80=99 [-Wmissing-prototyp=
es]
drivers/isdn/hardware/mISDN/avmfritz.c:966:1: warning: no previous prot=
otype for =E2=80=98setup_fritz=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/mISDN/avmfritz.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hard=
ware/mISDN/avmfritz.c
index 292991c..e3fa1cd 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -284,7 +284,7 @@ __write_ctrl_pciv2(struct fritzcard *fc, struct hdl=
c_hw *hdlc, u32 channel) {
 					  AVM_HDLC_STATUS_1));
 }
=20
-void
+static void
 write_ctrl(struct bchannel *bch, int which) {
 	struct fritzcard *fc =3D bch->hw;
 	struct hdlc_hw *hdlc;
@@ -741,7 +741,7 @@ inithdlc(struct fritzcard *fc)
 	modehdlc(&fc->bch[1], -1);
 }
=20
-void
+static void
 clear_pending_hdlc_ints(struct fritzcard *fc)
 {
 	u32 val;
@@ -962,7 +962,7 @@ avm_dctrl(struct mISDNchannel *ch, u32 cmd, void *a=
rg)
 	return err;
 }
=20
-int
+static int
 setup_fritz(struct fritzcard *fc)
 {
 	u32 val, ver;
--=20
1.7.9.5
