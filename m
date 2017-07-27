From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: tc35815: fix spelling mistake: "Intterrupt" -> "Interrupt"
Date: Thu, 27 Jul 2017 23:15:09 +0100
Message-ID: <20170727221509.12260-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Jarod Wilson <jarod@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in printk message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/toshiba/tc35815.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index d9db8a06afd2..cce9c9ed46aa 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -1338,7 +1338,7 @@ static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 static void tc35815_fatal_error_interrupt(struct net_device *dev, u32 status)
 {
 	static int count;
-	printk(KERN_WARNING "%s: Fatal Error Intterrupt (%#x):",
+	printk(KERN_WARNING "%s: Fatal Error Interrupt (%#x):",
 	       dev->name, status);
 	if (status & Int_IntPCI)
 		printk(" IntPCI");
-- 
2.11.0
