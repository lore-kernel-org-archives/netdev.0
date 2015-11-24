From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: dsa: fix build failure
Date: Tue, 24 Nov 2015 19:06:46 +0530
Message-ID: <1448372206-20138-1-git-send-email-sudipm.mukherjee@gmail.com>
References: <20151124152644.19ae110a@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151124152644.19ae110a@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were getting build failure with allmodconfig of tile, tilegx, m32r and m68k
with the error:
implicit declaration of function 'gpio_to_desc'
implicit declaration of function 'gpiod_direction_output'

Fixes: cc30c16344fc ("net: dsa: Add support for a switch reset gpio")
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

build log of next-20151124 at:
https://travis-ci.org/sudipm-mukherjee/parport/builds/92864660

 net/dsa/dsa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0b5565f..b7448c8 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -24,6 +24,7 @@
 #include <linux/of_gpio.h>
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
+#include <linux/gpio/consumer.h>
 #include "dsa_priv.h"
 
 char dsa_driver_version[] = "0.1";
-- 
1.9.1
