From: Junchang Wang <junchangwang@gmail.com>
Subject: [Patch]r8169: remove unnecessary cast of readl()'s return value
Date: Sun, 30 May 2010 20:26:07 +0800
Message-ID: <20100530122606.GC1146@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51646 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801Ab0E3MZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 08:25:54 -0400
Received: by pvg11 with SMTP id 11so995977pvg.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 05:25:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

readl() returns a 32-bit integer on all platforms.
There is no need to cast its return value.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..ca93cdf 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -88,7 +88,7 @@ static const int multicast_filter_limit = 32;
 #define RTL_W32(reg, val32)	writel ((val32), ioaddr + (reg))
 #define RTL_R8(reg)		readb (ioaddr + (reg))
 #define RTL_R16(reg)		readw (ioaddr + (reg))
-#define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
+#define RTL_R32(reg)		readl (ioaddr + (reg))
 
 enum mac_version {
 	RTL_GIGA_MAC_NONE   = 0x00,
--
