From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: dsa: b53: Add missing ULL suffix for 64-bit constant
Date: Wed,  3 Aug 2016 21:42:18 +0200
Message-ID: <1470253338-8210-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from michel.telenet-ops.be ([195.130.137.88]:60314 "EHLO
	michel.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310AbcHCTnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 15:43:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 32-bit (e.g. with m68k-linux-gnu-gcc-4.1):

    drivers/net/dsa/b53/b53_common.c: In function ‘b53_arl_read’:
    drivers/net/dsa/b53/b53_common.c:1072: warning: integer constant is too large for ‘long’ type

Fixes: 1da6df85c6fbed8f ("net: dsa: b53: Implement ARL add/del/dump operations")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/dsa/b53/b53_regs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index 8f12bddd5dc90077..a0b453ea34c90423 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -258,7 +258,7 @@
  * BCM5325 and BCM5365 share most definitions below
  */
 #define B53_ARLTBL_MAC_VID_ENTRY(n)	(0x10 * (n))
-#define   ARLTBL_MAC_MASK		0xffffffffffff
+#define   ARLTBL_MAC_MASK		0xffffffffffffULL
 #define   ARLTBL_VID_S			48
 #define   ARLTBL_VID_MASK_25		0xff
 #define   ARLTBL_VID_MASK		0xfff
-- 
1.9.1
