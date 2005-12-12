From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/gianfar.h: "extern inline" -> "static inline"
Date: Mon, 12 Dec 2005 02:35:28 +0100
Message-ID: <20051212013528.GE23349@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751024AbVLLBit@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 18 Nov 2005

 drivers/net/gianfar.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.15-rc1-mm1-full/drivers/net/gianfar.h.old	2005-11-18 02:38:02.000000000 +0100
+++ linux-2.6.15-rc1-mm1-full/drivers/net/gianfar.h	2005-11-18 02:38:10.000000000 +0100
@@ -711,14 +711,14 @@
 	uint32_t msg_enable;
 };
 
-extern inline u32 gfar_read(volatile unsigned *addr)
+static inline u32 gfar_read(volatile unsigned *addr)
 {
 	u32 val;
 	val = in_be32(addr);
 	return val;
 }
 
-extern inline void gfar_write(volatile unsigned *addr, u32 val)
+static inline void gfar_write(volatile unsigned *addr, u32 val)
 {
 	out_be32(addr, val);
 }
