From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Subject: [PATCH 1/1] driver/net: remove unused code in cosa module
Date: Mon, 14 Apr 2014 18:08:36 +0800
Message-ID: <1397470116-19669-1-git-send-email-zhen-hual@hp.com>
Cc: "Li, Zhen-Hua" <zhen-hual@hp.com>
To: <kas@fi.muni.cz>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Li, Zhen-Hua" <zhen-hual@hp.com>

For the cosa module, CONFIG_COSA can only be checked as 'm',
and cosa module can only be compiled as a module.

So remove unused code in cosa.c

Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
---
 drivers/net/wan/cosa.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 84734a8..83c39e2 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -1521,11 +1521,7 @@ static int cosa_reset_and_read_id(struct cosa_data *cosa, char *idstring)
 	cosa_putstatus(cosa, 0);
 	cosa_getdata8(cosa);
 	cosa_putstatus(cosa, SR_RST);
-#ifdef MODULE
 	msleep(500);
-#else
-	udelay(5*100000);
-#endif
 	/* Disable all IRQs from the card */
 	cosa_putstatus(cosa, 0);
 
-- 
1.7.10.4
