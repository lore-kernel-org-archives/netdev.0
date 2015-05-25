From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] atm:he - Do not initialise statics to 0.
Date: Tue, 26 May 2015 01:23:53 +0530
Message-ID: <1432583633-5129-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Chas Williams <3chas3@gmail.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Static variables are initialised to 0 by GCC.
Fixes the following checkpatch error:
ERROR: do not initialise statics to 0 or NULL
FILE: drivers/atm/he.c:120:
static bool sdh = 0;

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/atm/he.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 93dca2e..2cd6f17 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -117,7 +117,7 @@ static short nvpibits = -1;
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
 static bool irq_coalesce = 1;
-static bool sdh = 0;
+static bool sdh;
 
 /* Read from EEPROM = 0000 0011b */
 static unsigned int readtab[] = {
-- 
1.7.9.5
