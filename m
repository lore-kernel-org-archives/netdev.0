From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] ethernet: moxa: remove duplicate includes
Date: Sun, 20 Oct 2013 07:13:56 +0200
Message-ID: <1382246036-19253-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reported by "make includecheck"

Tested that drivers/net/ethernet/moxa/moxart_ether.c still compiles
well on ARM

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index bd1a2d2..7d4c8cc 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -26,7 +26,6 @@
 #include <linux/of_irq.h>
 #include <linux/crc32.h>
 #include <linux/crc32c.h>
-#include <linux/dma-mapping.h>
 
 #include "moxart_ether.h"
 
-- 
1.8.1.2
