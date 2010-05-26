From: Junchang Wang <junchangwang@gmail.com>
Subject: [Patch] r8169: use u32 instead of unsigned long
Date: Wed, 26 May 2010 22:01:11 +0800
Message-ID: <AANLkTimxRFZtwWOEXZ7pNfUER1Qw_rolb0YcxLFfRwyK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40265 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035Ab0EZOBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 10:01:13 -0400
Received: by pvg3 with SMTP id 3so1106435pvg.19
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 07:01:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTL_R32 should return value with 32-bit width. But "unsigned long"
implies u64 on some 64-bit platforms.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/r8169.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..4234d6a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -88,7 +88,7 @@ static const int multicast_filter_limit = 32;
 #define RTL_W32(reg, val32)	writel ((val32), ioaddr + (reg))
 #define RTL_R8(reg)		readb (ioaddr + (reg))
 #define RTL_R16(reg)		readw (ioaddr + (reg))
-#define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
+#define RTL_R32(reg)		((u32) readl(ioaddr + (reg)))

 enum mac_version {
 	RTL_GIGA_MAC_NONE   = 0x00,
--


--Junchang
