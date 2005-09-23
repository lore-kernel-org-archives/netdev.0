From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 2/8] orinoco: Make nortel_pci_hw_init() static.
Date: Fri, 23 Sep 2005 04:18:06 -0400
Message-ID: <E1EIikw-0003qZ-TX@gnu.org>
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Make nortel_pci_hw_init() static.

Found by sparse.

diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -92,7 +92,7 @@ static int nortel_pci_cor_reset(struct o
 	return 0;
 }
 
-int nortel_pci_hw_init(struct nortel_pci_card *card)
+static int nortel_pci_hw_init(struct nortel_pci_card *card)
 {
 	int i;
 	u32 reg;



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
