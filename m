From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/pch_gbe: Use DEFINE_PCI_DEVICE_TABLE
Date: Thu, 14 Oct 2010 12:55:50 -0700
Message-ID: <1287086150.1117.608.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2970 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925Ab0JNTzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 15:55:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the standard macro to put this table in __devinitconst.

Compiled, untested.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index e44644f..cf4b49d 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -2394,7 +2394,7 @@ err_disable_device:
 	return ret;
 }
 
-static const struct pci_device_id pch_gbe_pcidev_id[] = {
+static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
 	{.vendor = PCI_VENDOR_ID_INTEL,
 	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
 	 .subvendor = PCI_ANY_ID,


