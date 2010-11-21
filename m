From: Joe Perches <joe@perches.com>
Subject: [PATCH 37/62] r8169: Use static const
Date: Sat, 20 Nov 2010 18:38:38 -0800
Message-ID: <400a1fb40ac73a27cd214d535d312c372e961643.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  43939	    232	   9904	  54075	   d33b	drivers/net/r8169.o.new
  43974	    232	   9904	  54110	   d35e	drivers/net/r8169.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d33ef4..f9ad0d6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2516,7 +2516,7 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 
 		val = mdio_read(ioaddr, 0x0d);
 		if ((val & 0x00ff) != 0x006c) {
-			u32 set[] = {
+			static const u32 set[] = {
 				0x0065, 0x0066, 0x0067, 0x0068,
 				0x0069, 0x006a, 0x006b, 0x006c
 			};
-- 
1.7.3.2.245.g03276.dirty
