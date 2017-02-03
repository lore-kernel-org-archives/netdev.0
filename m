From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queu 08/19] i40evf: remove unused device ID
Date: Thu,  2 Feb 2017 23:25:42 -0800
Message-ID: <20170203072553.168372-9-jeffrey.t.kirsher@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50618 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752712AbdBCHZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 02:25:57 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This device ID was intended for use when running Linux VF drivers under
Hyper-V, but we have determined that it is not necessary. Since it is
unused, and will never be used, remove it.

Change-ID: I74998ab4237db043cd400547bb54a0a5e2a37ea5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index c0fc533..3fe87e0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -59,7 +59,6 @@ static const struct pci_device_id i40evf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_VF), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_VF_HV), 0},
 	{PCI_VDEVICE(INTEL, I40E_DEV_ID_X722_VF), 0},
-	{PCI_VDEVICE(INTEL, I40E_DEV_ID_X722_VF_HV), 0},
 	/* required last entry */
 	{0, }
 };
-- 
2.10.2
