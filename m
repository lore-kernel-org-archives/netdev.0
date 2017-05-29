From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 01/17] net: qualcomm: qca_7k: clean up header includes
Date: Mon, 29 May 2017 13:57:09 +0200
Message-ID: <1496059045-13572-2-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the includes doesn't reflect the dependencies. So
fix this up by removing all unnecessary entries and add the
necessary ones explicit.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_7k.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
index f0066fb..e9162e1 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k.c
@@ -23,11 +23,9 @@
  *   kernel-based SPI device.
  */
 
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/moduleparam.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
 #include <linux/spi/spi.h>
-#include <linux/version.h>
 
 #include "qca_7k.h"
 
-- 
2.1.4
