From: Thomas Faber <thfabba@gmx.de>
Subject: [PATCH] net: ftgmac100/ftmac100: add missing interrupt.h include
Date: Thu, 19 Jan 2012 00:45:44 +0100
Message-ID: <4F1759A8.5080209@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Po-Yu Chuang <ratbert@faraday-tech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:53527 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753321Ab2ARXpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 18:45:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes compilation failure of these modules due to missing
irqreturn_t type for the ft(g)mac100_interrupt definition.

Signed-off-by: Thomas Faber <thfabba@gmx.de>
---
 drivers/net/ethernet/faraday/ftgmac100.c |    1 +
 drivers/net/ethernet/faraday/ftmac100.c  |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index fb5579a..47f85c3 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -25,6 +25,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index a127cb2..bb336a0 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -25,6 +25,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/mii.h>
 #include <linux/module.h>
--
1.7.3.4
