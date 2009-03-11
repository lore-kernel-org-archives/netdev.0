From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] bmac: remove unused variable bp in bmac_misc_intr()
Date: Wed, 11 Mar 2009 13:39:04 -0400
Message-ID: <20090311173901.16256.27381.stgit@np.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:57145 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009AbZCKRjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 13:39:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---

 drivers/net/bmac.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 8a546a3..4541bfb 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1062,7 +1062,6 @@ static int miscintcount;
 static irqreturn_t bmac_misc_intr(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct bmac_data *bp = netdev_priv(dev);
 	unsigned int status = bmread(dev, STATUS);
 	if (miscintcount++ < 10) {
 		XXDEBUG(("bmac_misc_intr\n"));
