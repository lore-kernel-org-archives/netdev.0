From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: PATCH drivers:net:cris/eth_v10: alternate string char arrary
Date: Mon, 24 Apr 2017 19:49:39 +0200
Message-ID: <1493056179-6460-1-git-send-email-karim.eshapa@gmail.com>
Cc: felipe.balbi@linux.intel.com, paul.gortmaker@windriver.com,
        mugunthanvnm@ti.com, jarod@redhat.com, fw@strlen.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Karim Eshapa <karim.eshapa@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

static char pointer creates two variables in final assembly.
static string and pointer to it according to
Jeff Garzik janitors TODO.

Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
---
 drivers/net/cris/eth_v10.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 91c876a..370765f 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -44,7 +44,7 @@
  * io regions, irqs and dma channels
  */
 
-static const char* cardname = "ETRAX 100LX built-in ethernet controller";
+static const char cardname[] = "ETRAX 100LX built-in ethernet controller";
 
 /* A default ethernet address. Highlevel SW will set the real one later */
 
-- 
2.7.4
