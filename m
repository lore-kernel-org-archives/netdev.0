From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: Adding PCI ID for Solarflare 7000 series
 40G network adapter.
Date: Mon, 14 Jul 2014 08:38:49 +0100
Message-ID: <53C38909.1080104@solarflare.com>
References: <53C388A2.5040705@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:40411 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbaGNHrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 03:47:40 -0400
In-Reply-To: <53C388A2.5040705@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mateusz Wrzesinski <mwrzesinski@solarflare.com>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 1e27404..2d86224 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2607,6 +2607,8 @@ static DEFINE_PCI_DEVICE_TABLE(efx_pci_table) = {
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0903),  /* SFC9120 PF */
 	 .driver_data = (unsigned long) &efx_hunt_a0_nic_type},
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0923),  /* SFC9140 PF */
+	 .driver_data = (unsigned long) &efx_hunt_a0_nic_type},
 	{0}			/* end of list */
 };
 
