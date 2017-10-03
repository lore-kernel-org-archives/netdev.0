From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH RESEND net 1/9] net/smc9194: Remove bogus CONFIG_MAC reference
Date: Mon,  2 Oct 2017 21:07:18 -0400 (EDT)
Message-ID: <84a5da837e7b8f720b560416b6f1704729f4954d.1506992619.git.fthain@telegraphics.com.au>
References: <cover.1506992619.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1506992619.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The only version of smc9194.c with Mac support is the one in the
linux-mac68k CVS repo. AFAIK that driver never made it to the mainline.

Despite that, as of v2.3.45, arch/m68k/config.in listed CONFIG_SMC9194
under CONFIG_MAC. This mistake got carried over into Kconfig in v2.5.55.
(See pre-git era "[PATCH] add m68k dependencies to net driver config".)

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/smsc/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 63aca9f847e1..4c2f612e4414 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -20,7 +20,7 @@ if NET_VENDOR_SMSC
 
 config SMC9194
 	tristate "SMC 9194 support"
-	depends on (ISA || MAC && BROKEN)
+	depends on ISA
 	select CRC32
 	---help---
 	  This is support for the SMC9xxx based Ethernet cards. Choose this
-- 
2.13.5
