From: Dave Hansen <dave@sr71.net>
Subject: [PATCH] net: driver: samsung: keep off in Kconfig by default
Date: Wed, 14 May 2014 11:24:16 -0700
Message-ID: <20140514182416.106B1904@viggo.jf.intel.com>
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, joe@perches.com, bh74.an@samsung.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

These are a pet peeve of mine: Kconfig options that very few
people need turned on, but that default to y.

I know that this doesn't generate any code by itself, but it
does get in the way of every single person that does an
oldconfig.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Siva Reddy Kallam <siva.kallam@samsung.com>
Cc: Vipul Pandya <vipul.pandya@samsung.com>
Cc: Girish K S <ks.giri@samsung.com>
Cc: Joe Perches <joe@perches.com>
Cc: Byungho An <bh74.an@samsung.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---

 b/drivers/net/ethernet/samsung/Kconfig |    1 -
 1 file changed, 1 deletion(-)

diff -puN drivers/net/ethernet/samsung/Kconfig~turn-off-samsung-on-by-default drivers/net/ethernet/samsung/Kconfig
--- a/drivers/net/ethernet/samsung/Kconfig~turn-off-samsung-on-by-default	2014-05-14 11:17:06.213259966 -0700
+++ b/drivers/net/ethernet/samsung/Kconfig	2014-05-14 11:17:14.440628851 -0700
@@ -4,7 +4,6 @@
 
 config NET_VENDOR_SAMSUNG
 	bool "Samsung Ethernet devices"
-	default y
 	---help---
 	  If you have a network (Ethernet) chipset belonging to this class,
 	  say Y.
_
