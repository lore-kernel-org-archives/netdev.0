From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] r8169 warning from 64 bit constant
Date: Mon, 3 May 2004 11:05:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040503110517.3a144b46@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Need 'ull' on end of a 64 bit constant to get rid of warning.

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	Mon May  3 11:02:57 2004
+++ b/drivers/net/r8169.c	Mon May  3 11:02:57 2004
@@ -1156,7 +1156,7 @@
 
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
-	desc->addr = 0x0badbadbadbadbad;
+	desc->addr = 0x0badbadbadbadbadull;
 	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
 }
 
