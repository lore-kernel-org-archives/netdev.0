From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 01/11] ixgb: Fix compilation errors by initializing variables
Date: Fri, 21 Apr 2006 18:00:32 -0700
Message-ID: <20060422010031.24255.54593.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:32685 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750806AbWDVA52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- initialized varaibles
- rev'd driver version

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index cfd67d8..0b9481a 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -52,7 +52,7 @@ static char ixgb_driver_string[] = "Inte
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION		"1.0.100-k2"DRIVERNAPI
+#define DRV_VERSION		"1.0.104-k2"DRIVERNAPI
 char ixgb_driver_version[] = DRV_VERSION;
 static char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 
@@ -346,7 +346,7 @@ ixgb_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
-	struct ixgb_adapter *adapter;
+	struct ixgb_adapter *adapter = NULL;
 	static int cards_found = 0;
 	unsigned long mmio_start;
 	int mmio_len;

