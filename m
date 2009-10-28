From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] be2net: Add the new PCI IDs to
	PCI_DEVICE_TABLE.
Date: Wed, 28 Oct 2009 22:53:59 +0530
Message-ID: <20091028172358.GA2190@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:53730 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752744AbZJ1RYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:24:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the PCI IDs for the next generation chip to the
PCI_DEVICE_ID table.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4520db7..43180dc 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -31,8 +31,10 @@ MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 
 static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
+	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID2) },
+	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID3) },
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
-- 
1.6.0.4

