From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] ray_cs: Change 1 to true for bool type variable.
Date: Wed, 27 May 2015 06:25:57 +0530
Message-ID: <1432688157-2678-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable translate is bool type.So assigning true instead of 1.

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/net/wireless/ray_cs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 477f863..0881ba8 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -143,7 +143,7 @@ static int psm;
 static char *essid;
 
 /* Default to encapsulation unless translation requested */
-static bool translate = 1;
+static bool translate = true;
 
 static int country = USA;
 
-- 
1.7.9.5
