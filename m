From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net/fsl_pq_mdio: add module license GPL
Date: Fri, 6 Nov 2009 19:50:28 +0100
Message-ID: <20091106185028.GA5198@www.tglx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:59838 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759052AbZKFSua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 13:50:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

or it will taint the kernel and fail to load becuase
of_address_to_resource() is GPL only.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/fsl_pq_mdio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d167090..947a02b 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -426,3 +426,4 @@ void fsl_pq_mdio_exit(void)
 	of_unregister_platform_driver(&fsl_pq_mdio_driver);
 }
 module_exit(fsl_pq_mdio_exit);
+MODULE_LICENSE("GPL");
-- 
1.6.2.5

