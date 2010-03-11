From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 08/37] drivers/watchdog: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:04:32 -0700
Message-ID: <20100311180431.4824.39881.stgit__21503.7264432342$1268331570$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63703 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933585Ab0CKSEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:04:35 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/watchdog/cpwd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/watchdog/cpwd.c b/drivers/watchdog/cpwd.c
index 37ea052..89da14f 100644
--- a/drivers/watchdog/cpwd.c
+++ b/drivers/watchdog/cpwd.c
@@ -576,7 +576,7 @@ static int __devinit cpwd_probe(struct of_device *op,
 	 * interrupt_mask register cannot be written, so no timer
 	 * interrupts can be masked within the PLD.
 	 */
-	str_prop = of_get_property(op->node, "model", NULL);
+	str_prop = of_get_property(op->dev.of_node, "model", NULL);
 	p->broken = (str_prop && !strcmp(str_prop, WD_BADMODEL));
 
 	if (!p->enabled)

