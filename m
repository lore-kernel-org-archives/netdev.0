From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] atm:he - Do not initialise statics to 0.
Date: Thu,  4 Jun 2015 20:11:00 +0530
Message-ID: <1433428860-3467-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Chas Williams <3chas3@gmail.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to <stdbool.h> false is always '0' and
Static variables are initialised to 0 by GCC.

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/atm/he.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 0237271..a8da3a5 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -117,7 +117,7 @@ static short nvpibits = -1;
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
 static bool irq_coalesce = true;
-static bool sdh = 0;
+static bool sdh;
 
 /* Read from EEPROM = 0000 0011b */
 static unsigned int readtab[] = {
-- 
1.9.1
