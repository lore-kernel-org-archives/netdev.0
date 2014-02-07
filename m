From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 14/26] drivers: isdn: Mark function as static in w6692.c
Date: Fri, 7 Feb 2014 18:06:15 +0530
Message-ID: <a825533c7ef63682bb42113546fe1741f2c4a5a0.1390408517.git.rashika.kheria@gmail.com>
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

Mark functions as static in hardware/mISDN/w6692.c because they ar enot
used outside this file.

This eliminates the following warnings in hardware/mISDN/w6692.c:
drivers/isdn/hardware/mISDN/w6692.c:851:6: warning: no previous prototy=
pe for =E2=80=98initW6692=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/mISDN/w6692.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardwar=
e/mISDN/w6692.c
index de69f68..2e24a05 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -848,7 +848,7 @@ dbusy_timer_handler(struct dchannel *dch)
 	}
 }
=20
-void initW6692(struct w6692_hw *card)
+static void initW6692(struct w6692_hw *card)
 {
 	u8	val;
=20
--=20
1.7.9.5
