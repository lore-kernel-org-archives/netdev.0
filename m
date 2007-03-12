From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 3/4] [TULIP]  Fix SytemError typo
Date: Mon, 12 Mar 2007 02:59:31 -0700
Message-ID: <20070312095912.309990000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965461AbXCLJ7h@vger.kernel.org>
Content-Disposition: inline; filename=tulip-system-error-typo
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix an annoying typo - SytemError -> SystemError

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/interrupt.c   |    4 ++--
 drivers/net/tulip/tulip.h       |    2 +-
 drivers/net/tulip/winbond-840.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

--- tulip-2.6-mm-linux.orig/drivers/net/tulip/interrupt.c
+++ tulip-2.6-mm-linux/drivers/net/tulip/interrupt.c
@@ -675,7 +675,7 @@ irqreturn_t tulip_interrupt(int irq, voi
 				if (tp->link_change)
 					(tp->link_change)(dev, csr5);
 			}
-			if (csr5 & SytemError) {
+			if (csr5 & SystemError) {
 				int error = (csr5 >> 23) & 7;
 				/* oops, we hit a PCI error.  The code produced corresponds
 				 * to the reason:
@@ -745,7 +745,7 @@ irqreturn_t tulip_interrupt(int irq, voi
 			  TxFIFOUnderflow |
 			  TxJabber |
 			  TPLnkFail |
-			  SytemError )) != 0);
+			  SystemError )) != 0);
 #else
 	} while ((csr5 & (NormalIntr|AbnormalIntr)) != 0);
 
--- tulip-2.6-mm-linux.orig/drivers/net/tulip/tulip.h
+++ tulip-2.6-mm-linux/drivers/net/tulip/tulip.h
@@ -132,7 +132,7 @@ enum pci_cfg_driver_reg {
 /* The bits in the CSR5 status registers, mostly interrupt sources. */
 enum status_bits {
 	TimerInt = 0x800,
-	SytemError = 0x2000,
+	SystemError = 0x2000,
 	TPLnkFail = 0x1000,
 	TPLnkPass = 0x10,
 	NormalIntr = 0x10000,
--- tulip-2.6-mm-linux.orig/drivers/net/tulip/winbond-840.c
+++ tulip-2.6-mm-linux/drivers/net/tulip/winbond-840.c
@@ -1148,7 +1148,7 @@ static irqreturn_t intr_handler(int irq,
 		}
 
 		/* Abnormal error summary/uncommon events handlers. */
-		if (intr_status & (AbnormalIntr | TxFIFOUnderflow | SytemError |
+		if (intr_status & (AbnormalIntr | TxFIFOUnderflow | SystemError |
 						   TimerInt | TxDied))
 			netdev_error(dev, intr_status);
 

--
