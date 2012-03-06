From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 2/2] cxgb4vf: Add support for Chelsio's T480-CR and T440-LP-CR adapters
Date: Tue,  6 Mar 2012 14:26:37 +0530
Message-ID: <1331024197-18474-2-git-send-email-vipul@chelsio.com>
References: <1331024197-18474-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1963 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758822Ab2CFI6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 03:58:07 -0500
In-Reply-To: <1331024197-18474-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds PCI device ids for Chelsio's T480-CR and T440-LP-CR
adapters.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 3f580c0..25e3308 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2890,6 +2890,8 @@ static struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0x4808, 0),	/* T420-cx */
 	CH_DEVICE(0x4809, 0),	/* T420-bt */
 	CH_DEVICE(0x480a, 0),   /* T404-bt */
+	CH_DEVICE(0x480d, 0),   /* T480-cr */
+	CH_DEVICE(0x480e, 0),   /* T440-lp-cr */
 	{ 0, }
 };
 
-- 
1.7.1
