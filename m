From: David Miller <davem@davemloft.net>
Subject: [PATCH 19/42] isdn: elsa_cs: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:30 -0700 (PDT)
Message-ID: <20110417.173330.229752875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51042
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753944Ab1DRAeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:05 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DCAB624C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'dev' is set but unused in
elsa_cs_config().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/elsa_cs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 496d477..9e5e87b 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -129,12 +129,10 @@ static int elsa_cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 
 static int __devinit elsa_cs_config(struct pcmcia_device *link)
 {
-    local_info_t *dev;
     int i;
     IsdnCard_t icard;
 
     dev_dbg(&link->dev, "elsa_config(0x%p)\n", link);
-    dev = link->priv;
 
     link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
 
-- 
1.7.4.3

