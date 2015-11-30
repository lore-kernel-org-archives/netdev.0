From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH v2 net-next 2/2] sfc: Add PCI ID for Solarflare 8000 series
 10/40G NIC
Date: Mon, 30 Nov 2015 09:05:47 +0000
Message-ID: <565C116B.1050904@solarflare.com>
References: <5655DC18.7090208@solarflare.com>
 <cover.1448874133.git.bkenward@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:63496 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016AbbK3JF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 04:05:59 -0500
In-Reply-To: <cover.1448874133.git.bkenward@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also add support for 7000 series 40G NIC VF.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4e82bcf..b405349 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2784,6 +2784,12 @@ static const struct pci_device_id efx_pci_table[] = {
 	 .driver_data = (unsigned long) &efx_hunt_a0_vf_nic_type},
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0923),  /* SFC9140 PF */
 	 .driver_data = (unsigned long) &efx_hunt_a0_nic_type},
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x1923),  /* SFC9140 VF */
+	 .driver_data = (unsigned long) &efx_hunt_a0_vf_nic_type},
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0a03),  /* SFC9220 PF */
+	 .driver_data = (unsigned long) &efx_hunt_a0_nic_type},
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x1a03),  /* SFC9220 VF */
+	 .driver_data = (unsigned long) &efx_hunt_a0_vf_nic_type},
 	{0}			/* end of list */
 };
 
-- 
2.4.3
