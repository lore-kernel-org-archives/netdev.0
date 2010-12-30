From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/15]drivers:net:wireless:iwlwifi Typo change diable to
	disable.
Date: Thu, 30 Dec 2010 15:07:56 -0800
Message-ID: <1293750484-1161-7-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-3-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-4-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-5-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-6-git-send-email-justinmattock@gmail.com>
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
In-Reply-To: <1293750484-1161-6-git-send-email-justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=spi-devel-general>
List-Post: <mailto:spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The below patch fixes a typo "diable" to "disable". Please let me know if this 
is correct or not.

Signed-off-by: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c     |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-core.c    |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-ict.c b/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
index a5dbfea..b5cb3be 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
@@ -197,7 +197,7 @@ static irqreturn_t iwl_isr(int irq, void *data)
 
  none:
 	/* re-enable interrupts here since we don't have anything to service. */
-	/* only Re-enable if diabled by irq  and no schedules tasklet. */
+	/* only Re-enable if disabled by irq  and no schedules tasklet. */
 	if (test_bit(STATUS_INT_ENABLED, &priv->status) && !priv->_agn.inta)
 		iwl_enable_interrupts(priv);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index c2636a7..9b912c0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1316,7 +1316,7 @@ static void iwl_irq_tasklet_legacy(struct iwl_priv *priv)
 	}
 
 	/* Re-enable all interrupts */
-	/* only Re-enable if diabled by irq */
+	/* only Re-enable if disabled by irq */
 	if (test_bit(STATUS_INT_ENABLED, &priv->status))
 		iwl_enable_interrupts(priv);
 
@@ -1530,7 +1530,7 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 	}
 
 	/* Re-enable all interrupts */
-	/* only Re-enable if diabled by irq */
+	/* only Re-enable if disabled by irq */
 	if (test_bit(STATUS_INT_ENABLED, &priv->status))
 		iwl_enable_interrupts(priv);
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 25fb391..8700ab3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1304,7 +1304,7 @@ irqreturn_t iwl_isr_legacy(int irq, void *data)
 
  none:
 	/* re-enable interrupts here since we don't have anything to service. */
-	/* only Re-enable if diabled by irq */
+	/* only Re-enable if disabled by irq */
 	if (test_bit(STATUS_INT_ENABLED, &priv->status))
 		iwl_enable_interrupts(priv);
 	spin_unlock_irqrestore(&priv->lock, flags);
-- 
1.6.5.2.180.gc5b3e


------------------------------------------------------------------------------
Learn how Oracle Real Application Clusters (RAC) One Node allows customers
to consolidate database storage, standardize their database environment, and, 
should the need arise, upgrade to a full multi-node Oracle RAC database 
without downtime or disruption
http://p.sf.net/sfu/oracle-sfdevnl
