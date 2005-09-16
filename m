From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 2/5] orinoco: Don't include <net/ieee80211.h> twice.
Date: Fri, 16 Sep 2005 02:16:52 -0400
Message-ID: <1126851412.3056.5.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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


diff-tree 0f6bb198d92cc7e2351dd65528d86305f77aa7aa (from 7c5bc25c778643f8cdf930ad8391b9eac24a16e4)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Fri Sep 16 00:50:00 2005 -0400

    Don't include <net/ieee80211.h> twice.

diff-tree 0f6bb198d92cc7e2351dd65528d86305f77aa7aa (from 7c5bc25c778643f8cdf930ad8391b9eac24a16e4)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Fri Sep 16 00:50:00 2005 -0400

    Don't include <net/ieee80211.h> twice.

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -92,12 +92,10 @@
 #include <linux/ethtool.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 #include <net/ieee80211.h>
 
-#include <net/ieee80211.h>
-
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/system.h>
 
 #include "hermes.h"


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
