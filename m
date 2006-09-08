From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 03/10] [TULIP] Make DS21143 printout match lspci output
Date: Fri, 08 Sep 2006 11:15:36 -0700
Message-ID: <20060908182023.089235000@linux.intel.com>
References: <20060908181533.771856000@linux.intel.com>
Cc: Thibaut Varene <varenet@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>,
	Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751144AbWIHSUo@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline; filename=tulip-make-ds21143-printout-match-lspci-output
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thibaut Varene <varenet@parisc-linux.org>

Signed-off-by: Thibaut Varene <varenet@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Signed-off-by: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/tulip_core.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/tulip_core.c
@@ -147,7 +147,7 @@ struct tulip_chip_table tulip_tbl[] = {
 	HAS_MII | HAS_MEDIA_TABLE | CSR12_IN_SROM | HAS_PCI_MWI, tulip_timer },
 
   /* DC21142, DC21143 */
-  { "Digital DS21143 Tulip", 128, 0x0801fbff,
+  { "Digital DS21142/43 Tulip", 128, 0x0801fbff,
 	HAS_MII | HAS_MEDIA_TABLE | ALWAYS_CHECK_MII | HAS_ACPI | HAS_NWAY
 	| HAS_INTR_MITIGATION | HAS_PCI_MWI, t21142_timer },
 

--
