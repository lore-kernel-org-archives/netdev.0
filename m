From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] Remove leftover #endif after introducing
 SO_REUSEPORT
Date: Fri, 25 Jan 2013 10:00:58 +0000
Message-ID: <20130125100058.GJ11342@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43109 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755924Ab3AYKBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 05:01:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 055dc21a1d (soreuseport: infrastructure) removed the #if 0
around SO_REUSEPORT without removing the corresponding #endif
thus causing the header guard to close early.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 arch/mips/include/uapi/asm/socket.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 7e27236..3e68bfb 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -29,7 +29,6 @@
 				   socket to transmit pending data.  */
 #define SO_OOBINLINE 0x0100	/* Receive out-of-band data in-band.  */
 #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
-#endif
 
 #define SO_TYPE		0x1008	/* Compatible name for SO_STYLE.  */
 #define SO_STYLE	SO_TYPE	/* Synonym */
