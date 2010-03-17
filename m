From: David Miller <davem@davemloft.net>
Subject: e1000e: Fix build with CONFIG_PM disabled.
Date: Tue, 16 Mar 2010 23:41:00 -0700 (PDT)
Message-ID: <20100316.234100.133957798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58590
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753264Ab0CQGki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 02:40:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I had to add the following patch to fix the build after
your changes.

Thanks.

e1000e: Fix build with CONFIG_PM disabled.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 79b33c5..b96532a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5475,6 +5475,7 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
+#ifdef CONFIG_PM
 static const struct dev_pm_ops e1000_pm_ops = {
 	.suspend  = e1000_suspend,
 	.resume   = e1000_resume,
@@ -5486,6 +5487,7 @@ static const struct dev_pm_ops e1000_pm_ops = {
 	.runtime_resume = e1000_runtime_resume,
 	.runtime_idle = e1000_idle,
 };
+#endif
 
 /* PCI Device API Driver */
 static struct pci_driver e1000_driver = {
-- 
1.6.6.1

