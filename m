From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] au1000_eth: Fix warnings.
Date: Sun, 24 Jun 2007 15:59:54 +0200
Message-ID: <20070624135953.GA16754@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:59824 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbXFXOBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 10:01:07 -0400
Received: from localhost.localdomain ([127.0.0.1]:64444 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021442AbXFXOBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 15:01:05 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed by including <linux/dma-mapping.h>:

  CC      drivers/net/au1000_eth.o
drivers/net/au1000_eth.c: In function 'au1000_probe':
drivers/net/au1000_eth.c:661: warning: implicit declaration of function 'dma_alloc_noncoherent'
drivers/net/au1000_eth.c:802: warning: implicit declaration of function 'dma_free_noncoherent'

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index c39ab80..c27cfce 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -34,7 +34,7 @@
  *
  *
  */
-
+#include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
