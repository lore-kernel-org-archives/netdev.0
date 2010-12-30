From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 09/15]drivers:usb:host Typo change diable to disable.
Date: Thu, 30 Dec 2010 15:07:58 -0800
Message-ID: <1293750484-1161-9-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-3-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-4-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-5-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-6-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-7-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-8-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ivtv-devel-jGorlIydJmRM656bX5wj8A@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org,
	"Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1293750484-1161-8-git-send-email-justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=spi-devel-general>
List-Post: <mailto:spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The below patch fixes a typo "diable" to "disable" and also fixes another typo in a comment. 
Please let me know if this is correct or not.

Signed-off-by: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
 drivers/usb/host/fhci-hcd.c |    4 ++--
 drivers/usb/host/fhci-tds.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/host/fhci-hcd.c b/drivers/usb/host/fhci-hcd.c
index 20092a2..12fd184 100644
--- a/drivers/usb/host/fhci-hcd.c
+++ b/drivers/usb/host/fhci-hcd.c
@@ -98,13 +98,13 @@ void fhci_usb_enable_interrupt(struct fhci_usb *usb)
 	usb->intr_nesting_cnt--;
 }
 
-/* diable the usb interrupt */
+/* disable the usb interrupt */
 void fhci_usb_disable_interrupt(struct fhci_usb *usb)
 {
 	struct fhci_hcd *fhci = usb->fhci;
 
 	if (usb->intr_nesting_cnt == 0) {
-		/* diable the timer interrupt */
+		/* disable the timer interrupt */
 		disable_irq_nosync(fhci->timer->irq);
 
 		/* disable the usb interrupt */
diff --git a/drivers/usb/host/fhci-tds.c b/drivers/usb/host/fhci-tds.c
index 7be548c..38fe058 100644
--- a/drivers/usb/host/fhci-tds.c
+++ b/drivers/usb/host/fhci-tds.c
@@ -271,8 +271,8 @@ void fhci_init_ep_registers(struct fhci_usb *usb, struct endpoint *ep,
 
 /*
  * Collect the submitted frames and inform the application about them
- * It is also prepearing the TDs for new frames. If the Tx interrupts
- * are diabled, the application should call that routine to get
+ * It is also preparing the TDs for new frames. If the Tx interrupts
+ * are disabled, the application should call that routine to get
  * confirmation about the submitted frames. Otherwise, the routine is
  * called frome the interrupt service routine during the Tx interrupt.
  * In that case the application is informed by calling the application
-- 
1.6.5.2.180.gc5b3e


------------------------------------------------------------------------------
Learn how Oracle Real Application Clusters (RAC) One Node allows customers
to consolidate database storage, standardize their database environment, and, 
should the need arise, upgrade to a full multi-node Oracle RAC database 
without downtime or disruption
http://p.sf.net/sfu/oracle-sfdevnl
