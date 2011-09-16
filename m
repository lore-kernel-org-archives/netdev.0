From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] can: ti_hecc: include linux/io.h
Date: Fri, 16 Sep 2011 19:57:43 +0200
Message-ID: <1316195863-18695-1-git-send-email-zonque@gmail.com>
Cc: Daniel Mack <zonque@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a build breakage for OMAP3 boards.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/can/ti_hecc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index a812492..2adc294 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -46,6 +46,7 @@
 #include <linux/skbuff.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
+#include <linux/io.h>
 
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
-- 
1.7.6
