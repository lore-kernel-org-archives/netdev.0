From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc3-mm2 2/5] r8169: wrong advertisement of VLAN features
Date: Mon, 4 Oct 2004 21:49:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004194949.GA20379@electric-eye.fr.zoreil.com>
References: <20041004194826.GA18404@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041004194826.GA18404@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removal of an advertisement for VLAN features which is redundant with
rtl8169_init_one().

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

diff -puN drivers/net/r8169.c~r8169-205 drivers/net/r8169.c
--- linux-2.6.9-rc3/drivers/net/r8169.c~r8169-205	2004-10-04 21:17:44.000000000 +0200
+++ linux-2.6.9-rc3-fr/drivers/net/r8169.c	2004-10-04 21:17:44.000000000 +0200
@@ -1166,8 +1166,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-
 	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK) && use_dac) {
 		tp->cp_cmd |= PCIDAC;

_
