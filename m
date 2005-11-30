From: Franck <vagabon.xyz@gmail.com>
Subject: [PATCH] Add MIPS dependency for dm9000 driver
Date: Wed, 30 Nov 2005 18:18:49 +0100
Message-ID: <cda58cb80511300918i7df1c60au@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751473AbVK3RSv@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The attached patch adds MIPS dependency for dm9000 ethernet
controller. Indeed this controller is used by some embedded platforms
based on MIPS CPUs.

Signed-Off-By: Franck Bui-Huu <franck.bui@gmail.com>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f15f909..1b00169 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -856,7 +856,7 @@ config SMC9194

 config DM9000
 	tristate "DM9000 support"
-	depends on ARM && NET_ETHERNET
+	depends on (ARM || MIPS) && NET_ETHERNET
 	select CRC32
 	select MII
 	---help---
