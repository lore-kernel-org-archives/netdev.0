From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] ixgbe: Fix build warning
Date: Tue, 26 May 2009 21:23:15 -0700
Message-ID: <20090527042315.9841.236.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34967 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbZE0EXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 00:23:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a build warning due to an unused label.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b67bb6b..bf11a65 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5394,7 +5394,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 err_register:
 	ixgbe_release_hw_control(adapter);
-err_hw_init:
 	ixgbe_clear_interrupt_scheme(adapter);
 err_sw_init:
 err_eeprom:

