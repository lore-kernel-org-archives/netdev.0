From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: [PATCH] 8139cp: fix duplicate loglevel in module load message
Date: Tue, 22 Sep 2009 15:05:39 +0100
Message-ID: <4AB8D9B3.4010805@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Alexander Beregalov <a.beregalov@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756648AbZIVOFl@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was introduced by b93d58 "8139*: convert printk() to pr_<foo>()":

[ 2256252443 ] <6>8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)

The "version" string is printed using pr_info(), so it doesn't need to
include a loglevel.

Signed-off-by: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
CC: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/8139cp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index d0dbbf3..6841a9a 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -87,7 +87,7 @@
 
 /* These identify the driver base version and may not be removed. */
 static char version[] =
-KERN_INFO DRV_NAME ": 10/100 PCI Ethernet driver v" DRV_VERSION " (" DRV_RELDATE ")\n";
+DRV_NAME ": 10/100 PCI Ethernet driver v" DRV_VERSION " (" DRV_RELDATE ")\n";
 
 MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
 MODULE_DESCRIPTION("RealTek RTL-8139C+ series 10/100 PCI Ethernet driver");
-- 
1.6.3.2
