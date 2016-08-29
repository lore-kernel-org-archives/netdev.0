From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] mISDN: mark symbols static where possible
Date: Mon, 29 Aug 2016 19:59:33 +0800
Message-ID: <1472471973-23041-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when biuld kernel with W=1:
drivers/isdn/hardware/mISDN/w6692.c:851:6: warning: no previous prototype for 'initW6692' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is declared
and don't need a declaration, but can be made static.
so this patch marks it 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hardware/mISDN/w6692.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 7416755..3b067ea 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -848,7 +848,7 @@ dbusy_timer_handler(struct dchannel *dch)
 	}
 }
 
-void initW6692(struct w6692_hw *card)
+static void initW6692(struct w6692_hw *card)
 {
 	u8	val;
 
-- 
2.7.4
