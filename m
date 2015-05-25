From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] atm:he - Change 1 to true for bool type variable.
Date: Tue, 26 May 2015 01:17:23 +0530
Message-ID: <1432583243-5075-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Chas Williams <3chas3@gmail.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable irq_coalesce is bool type.
So assign the value true instead of 1.

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/atm/he.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 93dca2e..0237271 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -116,7 +116,7 @@ static bool disable64;
 static short nvpibits = -1;
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
-static bool irq_coalesce = 1;
+static bool irq_coalesce = true;
 static bool sdh = 0;
 
 /* Read from EEPROM = 0000 0011b */
-- 
1.7.9.5
