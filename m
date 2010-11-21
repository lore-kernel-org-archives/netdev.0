From: Joe Perches <joe@perches.com>
Subject: [PATCH 25/62] irda: Use static const
Date: Sat, 20 Nov 2010 18:38:26 -0800
Message-ID: <5f4ab3811a7f1d2f9b59fa1426c67a5ee9e31f72.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  16352	    216	   4424	  20992	   5200	drivers/net/irda/donauboe.o.old
  16352	    216	   4424	  20992	   5200	drivers/net/irda/donauboe.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/donauboe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index b626ccc..f81d944 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -818,9 +818,9 @@ toshoboe_probe (struct toshoboe_cb *self)
 {
   int i, j, n;
 #ifdef USE_MIR
-  int bauds[] = { 9600, 115200, 4000000, 1152000 };
+  static const int bauds[] = { 9600, 115200, 4000000, 1152000 };
 #else
-  int bauds[] = { 9600, 115200, 4000000 };
+  static const int bauds[] = { 9600, 115200, 4000000 };
 #endif
   unsigned long flags;
 
-- 
1.7.3.2.245.g03276.dirty
