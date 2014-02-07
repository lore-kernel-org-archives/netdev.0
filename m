From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 15/26] drivers: isdn: Mark function as static in mISDNipac.c
Date: Fri, 7 Feb 2014 18:07:20 +0530
Message-ID: <5d52b7d0719e175dca22644e31549beae1f0b315.1390408517.git.rashika.kheria@gmail.com>
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

Mark functions as static in hardware/mISDN/mISDNipac.c because they are
not used outside this file.

This elimiantes the following warnings in hardware/mISDN/mISDNipac.c:
drivers/isdn/hardware/mISDN/mISDNipac.c:116:1: warning: no previous pro=
totype for =E2=80=98isac_empty_fifo=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/mISDN/mISDNipac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/har=
dware/mISDN/mISDNipac.c
index ccd7d85..e139abc 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -112,7 +112,7 @@ isac_ph_state_bh(struct dchannel *dch)
 	pr_debug("%s: TE newstate %x\n", isac->name, dch->state);
 }
=20
-void
+static void
 isac_empty_fifo(struct isac_hw *isac, int count)
 {
 	u8 *ptr;
--=20
1.7.9.5
