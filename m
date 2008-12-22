From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 16/27] drivers/net/skfp: fix sparse warnings: make symbols
	static
Date: Mon, 22 Dec 2008 20:17:18 +0100
Message-ID: <20081222191717.11807.35892.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853AbYLVTR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:17:27 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/skfp/skfddi.c:620:13: warning: symbol 'skfp_interrupt' was not declared. Should it be static?
  drivers/net/skfp/skfddi.c:687:25: warning: symbol 'skfp_ctl_get_stats' was not declared. Should it be static?
  drivers/net/skfp/skfddi.c:1232:6: warning: symbol 'CheckSourceAddress' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/skfp/skfddi.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 7fbd4f8..607efea 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -617,7 +617,7 @@ static int skfp_close(struct net_device *dev)
  *   Interrupts are disabled, then reenabled at the adapter.
  */
 
-irqreturn_t skfp_interrupt(int irq, void *dev_id)
+static irqreturn_t skfp_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct s_smc *smc;	/* private board structure pointer */
@@ -684,7 +684,7 @@ irqreturn_t skfp_interrupt(int irq, void *dev_id)
  *   independent.
  *
  */
-struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
+static struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
 {
 	struct s_smc *bp = netdev_priv(dev);
 
@@ -1229,7 +1229,7 @@ static void send_queued_packets(struct s_smc *smc)
  * Verify if the source address is set. Insert it if necessary.
  *
  ************************/
-void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
+static void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
 {
 	unsigned char SRBit;
 

