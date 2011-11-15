From: Joe Perches <joe@perches.com>
Subject: [PATCH] pch_gbe: Move #include of module.h
Date: Tue, 15 Nov 2011 15:56:14 -0800
Message-ID: <1321401374.21286.22.camel@Joe-Laptop>
References: <201111152255.pAFMtTo5005370@wpaz5.hot.corp.google.com>
	 <20111115.183808.2066749950387258221.davem@davemloft.net>
	 <20111115155210.69249eb9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, tomoya-linux@dsn.okisemi.com,
	toshiharu-linux@dsn.okisemi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33289 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755318Ab1KOX4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 18:56:15 -0500
In-Reply-To: <20111115155210.69249eb9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first #include must be pch_gbe.h as it
does a #define of pr_fmt.

Signed-off-by: Joe Perches <joe@perches.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
index 9c075ea..9cb5f91 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
@@ -18,8 +18,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
  */
 
-#include <linux/module.h>	/* for __MODULE_STRING */
 #include "pch_gbe.h"
+#include <linux/module.h>	/* for __MODULE_STRING */
 
 #define OPTION_UNSET   -1
 #define OPTION_DISABLED 0
