From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH 06/12] cxgb3: Use standard #defines for PCIe Capability ASPM
	fields
Date: Wed, 05 Dec 2012 13:57:50 -0700
Message-ID: <20121205205750.13851.10893.stgit@bhelgaas.mtv.corp.google.com>
References: <20121205205724.13851.50508.stgit@bhelgaas.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
To: linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f202.google.com ([209.85.213.202]:63434 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964819Ab2LEU5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 15:57:52 -0500
Received: by mail-ye0-f202.google.com with SMTP id l7so677654yen.1
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 12:57:51 -0800 (PST)
In-Reply-To: <20121205205724.13851.50508.stgit@bhelgaas.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the standard #defines rather than bare numbers for PCIe Capability
ASPM fields.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
CC: Divy Le Ray <divy@chelsio.com>
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index aef45d3..3dee686 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -3307,7 +3307,7 @@ static void config_pcie(struct adapter *adap)
 	    G_NUMFSTTRNSEQRX(t3_read_reg(adap, A_PCIE_MODE));
 	log2_width = fls(adap->params.pci.width) - 1;
 	acklat = ack_lat[log2_width][pldsize];
-	if (val & 1)		/* check LOsEnable */
+	if (val & PCI_EXP_LNKCTL_ASPM_L0S)	/* check LOsEnable */
 		acklat += fst_trn_tx * 4;
 	rpllmt = rpl_tmr[log2_width][pldsize] + fst_trn_rx * 4;
 
