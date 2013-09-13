From: akpm@linux-foundation.org
Subject: [patch 3/4] drivers/atm/he.c: convert to module_pci_driver
Date: Fri, 13 Sep 2013 14:52:03 -0700
Message-ID: <20130913215203.B721D31C1BF@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	clbchenlibo.chen@huawei.com, chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:58089 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab3IMVwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 17:52:04 -0400
Received: by mail-yh0-f73.google.com with SMTP id z20so228232yhz.2
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 14:52:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: drivers/atm/he.c: convert to module_pci_driver

Signed-off-by: Libo Chen <libo.chen@huawei.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/he.c |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff -puN drivers/atm/he.c~drivers-atm-he-convert-to-module_pci_driver drivers/atm/he.c
--- a/drivers/atm/he.c~drivers-atm-he-convert-to-module_pci_driver
+++ a/drivers/atm/he.c
@@ -2872,15 +2872,4 @@ static struct pci_driver he_driver = {
 	.id_table =	he_pci_tbl,
 };
 
-static int __init he_init(void)
-{
-	return pci_register_driver(&he_driver);
-}
-
-static void __exit he_cleanup(void)
-{
-	pci_unregister_driver(&he_driver);
-}
-
-module_init(he_init);
-module_exit(he_cleanup);
+module_pci_driver(he_driver);
_
