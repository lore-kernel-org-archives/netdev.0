From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/62] cxgb3: Use static const
Date: Sat, 20 Nov 2010 18:38:13 -0800
Message-ID: <20d3c8494abd65f7a63cc7a51c6a1bbafa7552f2.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  42246	     56	   8816	  51118	   c7ae	drivers/net/cxgb3/t3_hw.o.new
  42198	    104	   8816	  51118	   c7ae	drivers/net/cxgb3/t3_hw.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cxgb3/t3_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 0b19704..d55db6b 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1562,7 +1562,7 @@ static void tp_intr_handler(struct adapter *adapter)
 		{0}
 	};
 
-	static struct intr_info tp_intr_info_t3c[] = {
+	static const struct intr_info tp_intr_info_t3c[] = {
 		{0x1fffffff, "TP parity error", -1, 1},
 		{F_FLMRXFLSTEMPTY, "TP out of Rx pages", -1, 1},
 		{F_FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1},
-- 
1.7.3.2.245.g03276.dirty
