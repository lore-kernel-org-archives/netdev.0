From: David Miller <davem@davemloft.net>
Subject: [PATCH 26/42] isdn: teles_cs: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:51 -0700 (PDT)
Message-ID: <20110417.173351.258108067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51063
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754081Ab1DRAe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5712824C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'dev' is set but unused in teles_cs_config().  Just
kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/teles_cs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index aa25e18..360f9ec 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -111,12 +111,10 @@ static int teles_cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 
 static int __devinit teles_cs_config(struct pcmcia_device *link)
 {
-    local_info_t *dev;
     int i;
     IsdnCard_t icard;
 
     dev_dbg(&link->dev, "teles_config(0x%p)\n", link);
-    dev = link->priv;
 
     i = pcmcia_loop_config(link, teles_cs_configcheck, NULL);
     if (i != 0)
-- 
1.7.4.3

