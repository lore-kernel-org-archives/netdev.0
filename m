From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix 64bit warnings in rtl8139too
Date: Tue, 7 Oct 2003 19:56:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007175638.GA1754@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix a harmless 64bit pointer/integer mismatch warning in 8139too.

diff -u linux-2.5-cleanup/drivers/net/8139too.c-o linux-2.5-cleanup/drivers/net/8139too.c
--- linux-2.5-cleanup/drivers/net/8139too.c-o	2003-09-08 00:02:03.000000000 +0200
+++ linux-2.5-cleanup/drivers/net/8139too.c	2003-12-02 17:13:24.634752560 +0100
@@ -746,7 +746,8 @@
 	u8 tmp8;
 	int rc;
 	unsigned int i;
-	u32 pio_start, pio_end, pio_flags, pio_len;
+	unsigned long pio_start;
+	u32 pio_end, pio_flags, pio_len;
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
 	u32 version;
 
