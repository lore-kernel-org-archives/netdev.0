From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] ptp_pch: Add missing #include <linux/slab.h>
Date: Wed, 16 May 2012 10:43:30 +0200
Message-ID: <1337157810-13494-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Takahiro Shimizu <tshimizu818@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/ptp/ptp_pch.c: In function 'pch_eth_enable_set':
drivers/ptp/ptp_pch.c:152:2: error: implicit declaration of function 'ioread32' [-Werror=implicit-function-declaration]
drivers/ptp/ptp_pch.c:153:2: error: implicit declaration of function 'iowrite32' [-Werror=implicit-function-declaration]

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Not even compile-tested, as it fails on parisc/xtensa only.
http://kisskb.ellerman.id.au/kisskb/buildresult/6312813/
http://kisskb.ellerman.id.au/kisskb/buildresult/6313050/

 drivers/ptp/ptp_pch.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 375eb04..6fff680 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/slab.h>
 
 #define STATION_ADDR_LEN	20
 #define PCI_DEVICE_ID_PCH_1588	0x8819
-- 
1.7.0.4
