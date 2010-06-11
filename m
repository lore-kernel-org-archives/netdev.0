From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 3/4] pcmcia: dev_node removal bugfix
Date: Fri, 11 Jun 2010 16:44:55 +0200
Message-ID: <1276267496-9836-3-git-send-email-linux@dominikbrodowski.net>
References: <20100611144359.GA9572@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:33964 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760276Ab0FKOpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 10:45:24 -0400
In-Reply-To: <20100611144359.GA9572@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch c7c2fa07 removed one line too much from smc91c92_cs.c.

Reported-by: Komuro <komurojun-mbn@nifty.com>
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/smc91c92_cs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 7b6fe89..64e6a84 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -322,6 +322,7 @@ static int smc91c92_probe(struct pcmcia_device *link)
 	return -ENOMEM;
     smc = netdev_priv(dev);
     smc->p_dev = link;
+    link->priv = dev;
 
     spin_lock_init(&smc->lock);
     link->io.NumPorts1 = 16;
-- 
1.7.0.4

