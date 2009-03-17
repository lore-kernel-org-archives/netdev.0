From: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Subject: [PATCH] sh_eth: Fix mistake of the address of SH7763
Date: Tue, 17 Mar 2009 14:52:23 +0900
Message-ID: <49BF3A97.4010008@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux-sh <linux-sh@vger.kernel.org>,
	Paul Mundt <lethal@linux-sh.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Address of SH_TSU_ADDR and ARSTR of SH7763 was wrong.
This revise it.

Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/sh_eth.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 73bc718..1537e13 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -43,8 +43,8 @@

 #define SH7763_SKB_ALIGN 32
 /* Chip Base Address */
-# define SH_TSU_ADDR  0xFFE01800
-# define ARSTR 		  0xFFE01800
+# define SH_TSU_ADDR	0xFEE01800
+# define ARSTR			SH_TSU_ADDR

 /* Chip Registers */
 /* E-DMAC */
-- 
1.6.2
