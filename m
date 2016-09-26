From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v2 net-next 1/8] net: qualcomm: remove unnecessary includes
Date: Mon, 26 Sep 2016 13:07:59 +0200
Message-ID: <1474888086-514-2-git-send-email-stefan.wahren@i2se.com>
References: <1474888086-514-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474888086-514-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the includes in qca_7k.c are unnecessary so we better remove them.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_7k.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
index f0066fb..557d53c 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k.c
@@ -23,11 +23,7 @@
  *   kernel-based SPI device.
  */
 
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/spi/spi.h>
-#include <linux/version.h>
 
 #include "qca_7k.h"
 
-- 
2.1.4
