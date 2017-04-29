From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: sunhme: fix spelling mistakes: "ParityErro" -> "ParityError"
Date: Sat, 29 Apr 2017 22:38:57 +0100
Message-ID: <20170429213857.11297-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistakes in printk message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/sun/sunhme.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index a6cc9a2d41c1..9e983e1d8249 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -1857,7 +1857,7 @@ static int happy_meal_is_not_so_happy(struct happy_meal *hp, u32 status)
 		if (status & GREG_STAT_TXLERR)
 			printk("LateError ");
 		if (status & GREG_STAT_TXPERR)
-			printk("ParityErro ");
+			printk("ParityError ");
 		if (status & GREG_STAT_TXTERR)
 			printk("TagBotch ");
 		printk("]\n");
-- 
2.11.0
