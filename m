From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] phy/micrel: Fix ID of KSZ9021
Date: Tue, 22 May 2012 09:20:08 +0900
Message-ID: <1337646008-24568-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: david.choi@micrel.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:60491 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab2EVANQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 20:13:16 -0400
Received: by dady13 with SMTP id y13so7468152dad.19
        for <netdev@vger.kernel.org>; Mon, 21 May 2012 17:13:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right ID of KSZ9021 is 0x00221610.
Because lower 4bit is a revision number, it varies according to a chip.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Cc: David J. Choi <david.choi@micrel.com>
---
 include/linux/micrel_phy.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index dd8da34..61f0905 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -3,7 +3,7 @@
 
 #define MICREL_PHY_ID_MASK	0x00fffff0
 
-#define PHY_ID_KSZ9021		0x00221611
+#define PHY_ID_KSZ9021		0x00221610
 #define PHY_ID_KS8737		0x00221720
 #define PHY_ID_KS8041		0x00221510
 #define PHY_ID_KS8051		0x00221550
-- 
1.7.10
