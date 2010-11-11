From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 05/10] cxgb4vf: flesh out PCI Device ID Table ...
Date: Wed, 10 Nov 2010 18:04:07 -0800
Message-ID: <1289441052-4925-5-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27943 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224Ab0KKCEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:21 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a bunch of T4 Device IDs for the VF Driver.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 9e9e4f6..75b85ca 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2834,6 +2834,14 @@ static struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0x4800, 0),	/* T440-dbg */
 	CH_DEVICE(0x4801, 0),	/* T420-cr */
 	CH_DEVICE(0x4802, 0),	/* T422-cr */
+	CH_DEVICE(0x4803, 0),	/* T440-cr */
+	CH_DEVICE(0x4804, 0),	/* T420-bch */
+	CH_DEVICE(0x4805, 0),   /* T440-bch */
+	CH_DEVICE(0x4806, 0),	/* T460-ch */
+	CH_DEVICE(0x4807, 0),	/* T420-so */
+	CH_DEVICE(0x4808, 0),	/* T420-cx */
+	CH_DEVICE(0x4809, 0),	/* T420-bt */
+	CH_DEVICE(0x480a, 0),   /* T404-bt */
 	{ 0, }
 };
 
-- 
1.7.0.4

